import Foundation

let path = URL(fileURLWithPath: "input-day5.txt")

guard var input = try? String(contentsOf: path) else {
  fatalError("failed to read \(path)")
}

input.remove(at: input.index(before: input.endIndex))

func doReact(_ a: UInt32, _ b: UInt32) -> Bool {
  return abs(Int(a) - Int(b)) == 32
}

class Node {
  let a: UInt32
  var next: Node? = nil
  var prev: Node? = nil
  init(_ c: UInt32) {
    a = c
  }
}

func countList(_ head: Node) -> Int {
  var count = 0
  var node: Node? = head
  while node != nil {
    node = node?.next
    count += 1
  }
  return count
}

func makePolymer(_ polymer: String, without char: UInt32) -> Node {
  let head = Node(0)
  var tail = Node(0)
  head.next = tail
  tail.prev = head
  var index = polymer.index(after: polymer.startIndex)
  repeat {
    let c = polymer[index].unicodeScalars.first!.value
    polymer.formIndex(after: &index)
    if c == char || c == char + 32 {
      continue
    }
    let node = Node(c)
    tail.next = node
    node.prev = tail
    tail = node
  } while index != polymer.endIndex
  for _ in 0...1 {
    let tail2 = Node(0)
    tail.next = tail2
    tail2.prev = tail
  }
  return head
}

func react(_ polymer: String, without char: UInt32) -> Int {

  let head = makePolymer(polymer, without: char)

  var node = head

  repeat {
    while doReact(node.a, node.next!.a) {
      node.prev!.next = node.next!.next
      node.next!.next!.prev = node.prev!
      node = node.prev!
    } 
    node = node.next!
  } while node.next!.next != nil 

  return countList(head) - 4
}


autoreleasepool {
  do {
    print(react(input, without: 0))
  }

  var minLength = Int.max
  for c in 65...90 {
    minLength = min(minLength, react(input, without: UInt32(c)))
  }
  print(minLength)
}
