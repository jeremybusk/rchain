package coop.rchain.node

import java.net.SocketAddress
import coop.rchain.comm.protocol.rchain.Packet
import coop.rchain.p2p, p2p.NetworkAddress, p2p.Network.KeysStore
import coop.rchain.p2p.effects._
import coop.rchain.comm._, CommError._
import coop.rchain.metrics.Metrics
import java.io.{File, FileInputStream, FileOutputStream, PrintWriter}
import java.nio.file.{Files, Path}

import scala.tools.jline._
import scala.tools.jline.console._, completer.StringsCompleter
import scala.collection.JavaConverters._

import cats._, cats.data._, cats.implicits._
import coop.rchain.catscontrib._
import Catscontrib._, ski._, TaskContrib._
import monix.eval.Task

package object effects {
  private def createDirectoryIfNotExists(path: Path): Path =
    if (Files.notExists(path)) Files.createDirectory(path) else path

  def encryption(keysPath: Path): Encryption[Task] = new Encryption[Task] {
    import Encryption._
    import coop.rchain.crypto.encryption.Curve25519
    import com.google.common.io.BaseEncoding

    val encoder = BaseEncoding.base16().lowerCase()

    private def generateFresh: Task[PublicPrivateKeys] = Task.delay {
      val (pub, sec) = Curve25519.newKeyPair
      PublicPrivateKeys(pub, sec)
    }

    private def storeToFS: PublicPrivateKeys => Task[Unit] =
      keys =>
        Task
          .delay {
            createDirectoryIfNotExists(keysPath.getParent)
            val pw = new PrintWriter(keysPath.toFile)
            pw.println(encoder.encode(keys.pub))
            pw.println(encoder.encode(keys.priv))
            pw.close()
          }
          .attempt
          .void

    private def fetchFromFS: Task[Option[PublicPrivateKeys]] =
      Task
        .delay {
          val lines  = scala.io.Source.fromFile(keysPath.toFile).getLines.toList
          val pubKey = encoder.decode(lines(0))
          val secKey = encoder.decode(lines(1))
          PublicPrivateKeys(pubKey, secKey)
        }
        .attempt
        .map(_.toOption)

    def fetchKeys: Task[PublicPrivateKeys] =
      (fetchFromFS >>= {
        case None     => generateFresh >>= (keys => storeToFS(keys) *> keys.pure[Task])
        case Some(ks) => ks.pure[Task]
      }).memoize

    def generateNonce: Task[Nonce] = Task.delay(Curve25519.newNonce)

    def encrypt(pub: Key, sec: Key, nonce: Nonce, message: Array[Byte]): Task[Array[Byte]] =
      Task.delay(Curve25519.encrypt(pub, sec, nonce, message))

    def decrypt(pub: Key, sec: Key, nonce: Nonce, cipher: Array[Byte]): Task[Array[Byte]] =
      Task.delay(Curve25519.decrypt(pub, sec, nonce, cipher))
  }

  def log: Log[Task] = new Log[Task] {
    import com.typesafe.scalalogging.Logger

    val logger = Logger("logger")

    def debug(msg: String): Task[Unit] = Task.delay(logger.debug(msg))
    def info(msg: String): Task[Unit]  = Task.delay(logger.info(msg))
    def warn(msg: String): Task[Unit]  = Task.delay(logger.warn(msg))
    def error(msg: String): Task[Unit] = Task.delay(logger.error(msg))
  }

  def time: Time[Task] = new Time[Task] {
    def currentMillis: Task[Long] = Task.delay {
      System.currentTimeMillis
    }
    def nanoTime: Task[Long] = Task.delay {
      System.nanoTime
    }
  }

  def remoteKeysKvs(remoteKeysPath: Path): Kvs[Task, PeerNode, Array[Byte]] =
    new Kvs[Task, PeerNode, Array[Byte]] {
      import com.google.protobuf.ByteString
      var m: Map[PeerNode, Array[Byte]] = fetch()

      def keys: Task[Vector[PeerNode]]                = Task.delay(m.keys.toVector)
      def get(k: PeerNode): Task[Option[Array[Byte]]] = Task.delay(m.get(k))
      def put(k: PeerNode, v: Array[Byte]): Task[Unit] = Task.delay {
        m = m + (k -> v)
        store()
      }

      def delete(k: PeerNode): Task[Unit] = Task.delay {
        m = m - k
        store()
      }

      private def fetch(): Map[PeerNode, Array[Byte]] = {
        createDirectoryIfNotExists(remoteKeysPath.getParent)
        val file = remoteKeysPath.toFile
        file.createNewFile()
        KeysStore
          .parseFrom(new FileInputStream(file))
          .keys
          .map {
            case (k, v) => (NetworkAddress.parse(k), v)
          }
          .flatMap {
            case (Right(peerNode), v) => Map(peerNode -> v.toByteArray)
            case (Left(_), _)         => Map.empty[PeerNode, Array[Byte]]
          }
      }

      private def store(): Unit =
        KeysStore(m.map {
          case (k, v) => (k.toAddress, ByteString.copyFrom(v))
        }).writeTo(new FileOutputStream(remoteKeysPath.toFile))
    }

  def nodeDiscovery[F[_]: Monad: Capture: Log: Time: Metrics](
      net: UnicastNetwork): NodeDiscovery[F] =
    new NodeDiscovery[F] {

      def addNode(node: PeerNode): F[Unit] =
        for {
          _ <- Capture[F].capture(net.add(node))
          _ <- Metrics[F].incrementGauge("peers")
        } yield ()

      def findMorePeers(limit: Int): F[Seq[PeerNode]] =
        Capture[F].capture {
          net.findMorePeers(limit)
        }

      def peers: F[Seq[PeerNode]] =
        Capture[F].capture {
          net.table.peers
        }

      def handleCommunications: ProtocolMessage => F[Option[ProtocolMessage]] =
        pm =>
          pm.sender.fold(none[ProtocolMessage].pure[F]) { sender =>
            pm match {
              case ping @ PingMessage(_, _)             => handlePing(sender, ping)
              case lookup @ LookupMessage(_, _)         => handleLookup(sender, lookup)
              case disconnect @ DisconnectMessage(_, _) => handleDisconnect(sender, disconnect)
              case _                                    => none[ProtocolMessage].pure[F]
            }
        }

      private def handlePing(sender: PeerNode, ping: PingMessage): F[Option[ProtocolMessage]] =
        ping
          .response(net.local)
          .traverse { pong =>
            Metrics[F].incrementCounter("ping-recv-count").as(pong)
          }

      /**
        * Validate incoming LOOKUP message and return an answering
        * LOOKUP_RESPONSE.
        */
      private def handleLookup(sender: PeerNode,
                               lookup: LookupMessage): F[Option[ProtocolMessage]] =
        (for {
          id   <- lookup.lookupId
          resp <- lookup.response(net.local, net.table.lookup(id))
        } yield {
          Metrics[F].incrementCounter("lookup-recv-count").as(resp)
        }).sequence

      /**
        * Remove sending peer from table.
        */
      private def handleDisconnect(sender: PeerNode,
                                   disconnect: DisconnectMessage): F[Option[ProtocolMessage]] =
        for {
          _ <- Log[F].info(s"Forgetting about $sender.")
          _ <- Capture[F].capture(net.table.remove(sender.key))
          _ <- Metrics[F].incrementCounter("disconnect-recv-count")
          _ <- Metrics[F].decrementGauge("peers")
        } yield none[ProtocolMessage]

    }

  def transportLayer(net: UnicastNetwork)(implicit
                                          ev1: Log[Task],
                                          ev2: Time[Task],
                                          ev3: Metrics[Task]): TransportLayer[Task] =
    new TransportLayer[Task] {
      import scala.concurrent.duration._

      def roundTrip(msg: ProtocolMessage,
                    remote: ProtocolNode,
                    timeout: Duration): Task[CommErr[ProtocolMessage]] =
        net.roundTrip[Task](msg, remote, timeout)

      def local: Task[ProtocolNode] = net.local.pure[Task]

      def commSend(msg: ProtocolMessage, peer: PeerNode): Task[CommErr[Unit]] =
        Task.delay(net.comm.send(msg.toByteSeq, peer))

      def broadcast(msg: ProtocolMessage): Task[Seq[CommErr[Unit]]] =
        Task.delay {
          net.broadcast(msg)
        }

      private def handle(dispatch: ProtocolMessage => Task[Option[ProtocolMessage]])
        : Option[ProtocolMessage] => Task[Unit] = _.fold(().pure[Task]) { pm =>
        dispatch(pm) >>= {
          case None => ().pure[Task]
          case Some(response) =>
            pm.sender.fold(Log[Task].error(s"Sender not available for $pm")) { sender =>
              commSend(response, sender) >>= {
                case Left(error) =>
                  Log[Task].warn(
                    s"Was unable to send response $response for request: $pm, error: $error")
                case _ => ().pure[Task]
              }
            }
        }
      }

      def receive(dispatch: ProtocolMessage => Task[Option[ProtocolMessage]]): Task[Unit] =
        net
          .receiver[Task]
          .flatMap(handle(dispatch))
          .forever
          .executeAsync
          .start
          .void
    }

  class JLineConsoleIO(console: ConsoleReader) extends ConsoleIO[Task] {
    def readLine: Task[String] = Task.delay {
      console.readLine
    }
    def println(str: String): Task[Unit] = Task.delay {
      console.println(str)
      console.flush()
    }
    def updateCompletion(history: Set[String]): Task[Unit] = Task.delay {
      console.getCompleters.asScala.foreach(c => console.removeCompleter(c))
      console.addCompleter(new StringsCompleter(history.asJava))
    }

    def close: Task[Unit] = Task.delay {
      TerminalFactory.get().restore()
    }

  }

  def packetHandler[F[_]: Applicative: Log](pf: PartialFunction[Packet, F[Option[Packet]]])(
      implicit errorHandler: ApplicativeError_[F, CommError]): PacketHandler[F] =
    new PacketHandler[F] {
      def handlePacket(packet: Packet): F[Option[Packet]] = {
        val errorMsg = s"Unable to handle packet $packet"
        if (pf.isDefinedAt(packet)) pf(packet)
        else
          Log[F].error(errorMsg) *> errorHandler
            .raiseError(unknownProtocol(errorMsg))
            .as(none[Packet])
      }
    }

}
