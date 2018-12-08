import Foundation

let path = URL(fileURLWithPath: "input-day8-test.txt")

guard let input = (try? String(contentsOf: path)) else {
  fatalError("failed to read \(path)")
}

class Node {
  var ccount: Int
  var mcount: Int
  var value: Int
  var c: [Node]
  var m: [Int]
  init(_ ccount: Int, _ mcount: Int) {
    self.ccount = ccount
    self.mcount = mcount
    value = 0
    c = []
    m = []
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
    if let cnode = stack.last {
      cnode.c.append(new)
    }
    stack.append(new)
    if ccount == 0 {
      state = .readingMetadata
    } 
  case .readingMetadata:
    let data = readInt()
    mdsum += data
    let node = stack.last!
    node.m.append(data)
    if node.m.count == node.mcount {
      if node.c.count == 0 {
        node.value = node.m.reduce(0, +)
      } else {
        for m in node.m {
          if m - 1 < node.c.count {
            node.value += node.c[m - 1].value
          }
        }
      }
      let last = stack.removeLast()
      if let cn = stack.last {
        if cn.c.count < cn.ccount {
          state = .readingHeader
        } else {
          state = .readingMetadata
        }
      } else {
        print(last.value)
        break loop
      }
    }
  }
    
    
}

print(mdsum)

