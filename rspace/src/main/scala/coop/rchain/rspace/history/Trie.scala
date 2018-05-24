package coop.rchain.rspace.history

import scodec.Codec
import scodec.codecs._

sealed trait Trie[+K, +V]                         extends Product with Serializable
final case class Leaf[K, V](key: K, value: V)     extends Trie[K, V]
final case class Node(pointerBlock: PointerBlock) extends Trie[Nothing, Nothing]

object Trie {

  def create[K, V](): Trie[K, V] = Node(PointerBlock.create())

  implicit def codecTrie[K, V](implicit codecK: Codec[K], codecV: Codec[V]): Codec[Trie[K, V]] =
    discriminated[Trie[K, V]]
      .by(uint8)
      .subcaseO(0) {
        case (leaf: Leaf[K, V]) => Some(leaf)
        case _                  => None
      }((codecK :: codecV).as[Leaf[K, V]])
      .subcaseO(1) {
        case (node: Node) => Some(node)
        case _            => None
      }(PointerBlock.codecPointerBlock.as[Node])
}
