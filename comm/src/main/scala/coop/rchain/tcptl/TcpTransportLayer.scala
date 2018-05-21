package coop.rchain.tcptl

import scala.concurrent.duration._
import java.net.SocketAddress
import coop.rchain.comm._, CommError._
import coop.rchain.comm.protocol.routing.{Protocol, TransportLayerGrpc}
import coop.rchain.p2p.effects._
import coop.rchain.metrics.Metrics
import io.grpc.{Server, ServerBuilder}

import cats._, cats.data._, cats.implicits._
import coop.rchain.catscontrib._
import Catscontrib._, ski._, TaskContrib._

import scala.concurrent.{ExecutionContext, Future}

class TcpTransportLayer[F[_]: Monad: Capture: Metrics](host: String, port: Int)(loc: ProtocolNode)(
    implicit executionContext: ExecutionContext)
    extends TransportLayer[F] {

  val server = ServerBuilder
    .forPort(port)
    .addService(TransportLayerGrpc.bindService(new TranportLayerImpl, executionContext))
    .build

  def roundTrip(msg: ProtocolMessage,
                remote: ProtocolNode,
                timeout: Duration): F[CommErr[ProtocolMessage]] = ???

  def local: F[ProtocolNode] = loc.pure[F]

  def commSend(msg: ProtocolMessage, peer: PeerNode): F[CommErr[Unit]] = ???

  def broadcast(msg: ProtocolMessage): F[Seq[CommErr[Unit]]] = ???

  def receive(dispatchdispatch: Option[ProtocolMessage] => F[Unit]): F[Unit] = ???
}

class TranportLayerImpl extends TransportLayerGrpc.TransportLayer {
  def run(request: Protocol): Future[Protocol] = ???

}
