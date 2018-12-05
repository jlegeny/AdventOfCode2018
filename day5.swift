import Foundation

let path = URL(fileURLWithPath: "input-day5.txt")

guard let input = try? String(contentsOf: path).replacingOccurrences(of: "\n", with: "") else {
  fatalError("failed to read \(path)")
}


func doReact(_ a: UInt32, _ b: UInt32) -> Bool {
  return abs(Int(a) - Int(b)) == 32
}

class Node {
  let a: UInt32
  var next: Node? = nil
  var prev: Node? = nil
  init(_ c: Character) {
    a = c.unicodeScalars.first!.value
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

func makePolymer(_ polymer: String) -> Node {
  let head = Node(polymer.first!)
  var tail = head
  var index = polymer.index(after: polymer.startIndex)
  repeat {
    let node = Node(polymer[index])
    tail.next = node
    node.prev = tail
    tail = node
    polymer.formIndex(after: &index)
  } while index != polymer.endIndex
  return head
}

func react(_ polymer: String) -> Int {

  let head = makePolymer(polymer)

  var node = head

  repeat {
    while doReact(node.a, node.next!.a) {
      node.prev!.next = node.next!.next
      node.next!.next!.prev = node.prev!
      node = node.prev!
    } 
    node = node.next!
  } while node.next!.next != nil 

  return countList(head)
}


do {
  let polymer = "//\(input)//"
  print(react(polymer) - 4)
}

var minLength = Int.max
for c in "abcdefghijklmnopqrstuvwxyz" {
  let polymer = input.replacingOccurrences(of: String(c), with: "", options: [.caseInsensitive])
  minLength = min(minLength, react("//\(polymer)//") - 4)
}
print(minLength)
