import Foundation

let path = URL(fileURLWithPath: "input-day8.txt")

guard let input = (try? String(contentsOf: path)) else {
  fatalError("failed to read \(path)")
}

class Node {
  var ccount: Int
  var mcount: Int
  var value: Int = 0
  var c: [Node] = []
  var m: [Int] = []
  init(_ ccount: Int, _ mcount: Int) {
    self.ccount = ccount
    self.mcount = mcount
  }
}

enum State {
  case readingHeader
  case readingMetadata
}

var stack: [Node] = []

let scanner = Scanner(string: input)
var readInt = { () -> Int in
  var value = 0
  scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
  if !scanner.scanInt(&value) {
    return -1
  }
  return value
}

var state: State = .readingHeader

var mdsum = 0

loop: while true {
  switch (state) {
  case .readingHeader:
    let ccount = readInt()
    let mcount = readInt()
    let new = Node(ccount, mcount)
    stack.last?.c.append(new)
    stack.append(new)
    state = ccount == 0 ? .readingMetadata : .readingHeader
  case .readingMetadata:
    let data = readInt()
    mdsum += data
    let node = stack.last!
    node.m.append(data)
    if node.m.count == node.mcount {
      if node.c.count == 0 {
        node.value = node.m.reduce(0, +)
      } else {
        node.value = node.m.reduce(0, { $0 + ($1 - 1 < node.c.count ? node.c[$1 - 1].value : 0) })
      }
      let last = stack.removeLast()
      guard let cn = stack.last else {
        print(last.value)
        break loop
      }
      state = cn.c.count < cn.ccount ? .readingHeader : .readingMetadata
    }
  }
}

print(mdsum)

