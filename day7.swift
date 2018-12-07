import Foundation

let path = URL(fileURLWithPath: "input-day7.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

let baseDuration = 60
let workers = 5

class Node {
  var time: Int
  var p = Set<Character>()
  init(c: Character) {
    self.time = baseDuration + Int(c.unicodeScalars.first!.value) - Int("A".unicodeScalars.first!.value) + 1
  }
}

var nodes1: [Character:Node] = [:]
var nodes2: [Character:Node] = [:]

let regex = try! NSRegularExpression(pattern: "Step (.) must be finished before step (.) can begin.", options: [])

for line in lines.dropLast() {
  let req = line[line.index(line.startIndex, offsetBy: 5)]
  let step = line[line.index(line.startIndex, offsetBy: 36)]

  func addTo(_ dict: inout [Character:Node]) {
    if dict[step] == nil {
      dict[step] = Node(c: step)
    }

    if dict[req] == nil {
      dict[req] = Node(c: req)
    }

    dict[step]!.p.insert(req)
  }

  addTo(&nodes1)
  addTo(&nodes2)

}

// Part 1
do {
  var nodes = nodes1
  var chain = ""

  var orderedKeys = nodes.keys.sorted()
  while nodes.count > 0 {

    for key in orderedKeys {
      if nodes[key]!.p.isEmpty {
        nodes.values.forEach { $0.p.remove(key) }
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
  var nodes = nodes2
  var duration = 0

  var orderedKeys = nodes.keys.sorted()
  while nodes.count > 0 {

    var available = workers
    for key in orderedKeys {
      if available == 0 {
        break
      }
      if let node = nodes[key], node.p.isEmpty {
        node.time -= 1
        available -= 1
      }
    }
    duration += 1
    nodes.filter({ $0.value.time == 0 }).keys.forEach {
      k in nodes.values.forEach { $0.p.remove(k) }
    }
    nodes = nodes.filter({ $0.value.time > 0 })
    orderedKeys = nodes.keys.sorted()
  }

  print(duration)
}


