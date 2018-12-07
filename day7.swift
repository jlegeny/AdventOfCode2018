import Foundation

let path = URL(fileURLWithPath: "input-day7.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

let baseDuration = 60
let workers = 5

class Node {
  let c: String
  var time: Int
  var p = Set<String>()
  init(c: String) {
    self.c = c
    self.time = baseDuration + Int(c.unicodeScalars.first!.value) - Int("A".unicodeScalars.first!.value) + 1
  }
}

var nodes: [String:Node] = [:]
var nodes2: [String:Node] = [:]

let regex = try! NSRegularExpression(pattern: "Step (.) must be finished before step (.) can begin.", options: [])

for line in lines {
  guard let m = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)).first else {
    break
  }

  let req = String(line[Range(m.range(at: 1), in: line)!])
  let step = String(line[Range(m.range(at: 2), in: line)!])

  if nodes[step] == nil {
    let node = Node(c: step)
    nodes[step] = node
    let node2 = Node(c: step)
    nodes2[step] = node2
  }

  if nodes[req] == nil {
    let node = Node(c: req)
    nodes[req] = node
    let node2 = Node(c: req)
    nodes2[req] = node2
  }

  nodes[step]!.p.insert(req)
  nodes2[step]!.p.insert(req)
}

// Part 1
do {
  var orderedKeys = nodes.keys.sorted()
  var chain = ""

  while nodes.count > 0 {

    for key in orderedKeys {
      if nodes[key]!.p.isEmpty {
        for n in nodes {
          n.value.p.remove(key) 
        }
        nodes[key] = nil
        orderedKeys = nodes.keys.sorted()
        chain.append(key)
        break
      }
    }
  }
  print(chain)
}

// Part 2

do {
  var orderedKeys = nodes2.keys.sorted()
  var duration = 0

  while nodes2.count > 0 {

    var available = workers
    for key in orderedKeys {
      if available == 0 {
        break
      }
      let node = nodes2[key]!
      if node.p.isEmpty {
        node.time -= 1
        available -= 1
      }
    }
    duration += 1
    for node in nodes2 {
      if node.value.time == 0 {
        for n in nodes2 {
          if n.value.p.contains(node.key) {
            n.value.p.remove(node.key)
          }
        }
      }
    }
    nodes2 = nodes2.filter({ $0.value.time > 0 })
    orderedKeys = nodes2.keys.sorted()
  }

  print(duration)
}
