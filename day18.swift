import Foundation

let path = URL(fileURLWithPath: "input-day18.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

var m = [[Int]](repeating: [Int](repeating: 0, count: lines.count - 1), count: lines.first!.count)
var m2 = [[Int]](repeating: [Int](repeating: 0, count: lines.count - 1), count: lines.first!.count)

do {
  var y = 0
  lines.dropLast().forEach {
    var x = 0
    for c in $0 {
      switch (c) {
      case ".":
        m[x][y] = 0
      case "|":
        m[x][y] = 1
      case "#":
        m[x][y] = 2
      default:
        break
      }
      x += 1
    }
    y += 1
  }
}

func printm(_ m: [[Int]]) {
  var cl = 0
  var ct = 0
  var l = ""
  for y in 0..<m.first!.count {
    for x in 0..<m.count {
      l += m[x][y] == 0 ? "." : (m[x][y] == 1 ? "|" : "#")
      if m[x][y] == 1 {
        ct += 1
      } else if m[x][y] == 2 {
        cl += 1
      }
    }
    l += "\n"
  }
  print(l)
  print(ct, cl, ct*cl)
}

func cycle(m: inout [[Int]], m2: inout [[Int]]) {
  
  for y in 0..<m.first!.count {
    for x in 0..<m.count {
      switch (m[x][y]) {
      case 0:
        var at = 0
        for dy in -1...1 {
          for dx in -1...1 {
            if (dx != 0 || dy != 0) && (0 <= x + dx)  && (x + dx < m.count) && (0 <= y + dy) && (y + dy < m.first!.count) && m[x + dx][y + dy] == 1 {
              at += 1
            }
            m2[x][y] = at >= 3 ? 1 : 0
          }
        }
      case 1:
        var al = 0
        for dy in -1...1 {
          for dx in -1...1 {
            if (dx != 0 || dy != 0) && (0 <= x + dx)  && (x + dx < m.count) && (0 <= y + dy) && (y + dy < m.first!.count) && m[x + dx][y + dy] == 2 {
              al += 1
            }
            m2[x][y] = al >= 3 ? 2 : 1
          }
        }
      case 2:
        var at = 0
        var al = 0
        for dy in -1...1 {
          for dx in -1...1 {
            if (dx != 0 || dy != 0) && (0 <= x + dx)  && (x + dx < m.count) && (0 <= y + dy) && (y + dy < m.first!.count) {
              if m[x + dx][y + dy] == 1 {
                at += 1
              } else if m[x + dx][y + dy] == 2 {
                al += 1
              }
            }
            m2[x][y] = (at >= 1 && al >= 1)  ? 2 : 0
          }
        }
      default:
        break
      }
    }
  }
  m = m2
}

printm(m)

var h = [[[Int]]]()
var l1 = 0
var l2 = 0
var p: [[Int]]? = nil

for c in 1...1000 {
  if let p = p, h.last == p {
    l2 = c - 1
    printm(p)
    break
  }
  if c & 1 == 1 {
    cycle(m: &m, m2: &m2)
    if p == nil && h.contains(m2) {
      l1 = c
      h.removeAll()
      p = m2
    } else {
      h.append(m2)
    }
  } else {
    cycle(m: &m2, m2: &m)
    if p == nil && h.contains(m) {
      l1 = c
      h.removeAll()
      p = m
    } else {
      h.append(m)
    }
  }
}

let max = 1000000000
//let max = 507


var n = l2
while n + (l2 - l1) < max-1 {
  n += l2 - l1
}

print(l1, l2, n)

var lm = [[Int]]()
for c in n+1...max {
  if c & 1 == 1 {
    cycle(m: &m, m2: &m2)
    lm = m2
  } else {
    cycle(m: &m2, m2: &m)
    lm = m
  }
}

printm(lm)
//low 185859
// high 181853
