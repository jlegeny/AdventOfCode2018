import Foundation

let path = URL(fileURLWithPath: "input-day6.txt")


guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

struct Position {
  let id: Int
  let x: Int
  let y: Int
}

var positions: [Position] = []

var posbyx: [Int:[Position]] = [:]
var posbyy: [Int:[Position]] = [:]


var mx = 0
var my = 0
var id = 0
lines.dropLast().forEach {
  var x = 0
  var y = 0
  let scanner = Scanner(string: $0)
  scanner.scanInt(&x)
  scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
  scanner.scanInt(&y)
  id += 1
  let p = Position(id: id, x: x, y: y)
  positions.append(p)
  mx = max(mx, x)
  my = max(my, y)
 }

//positions.forEach {
//  print($0)
//}

func dist(_ p1: (Int, Int), _ p2: (Int, Int)) -> Int {
  return abs(p1.0 - p2.0) + abs(p1.1 - p2.1)
}

let sortedx = posbyx.keys.sorted
let sortedy = posbyy.keys.sorted

var m = [[Int]](repeating: [Int](repeating: 0, count: my + 1), count: mx + 1)
//var t = [[Int]](repeating: [Int](repeating: 0, count: my + 1), count: mx + 1)


var tmax = 0
for x in 0...mx {
  for y in 0...my {
    var minid = 0
    var mindist = Int.max
    var t = 0
    for p in positions {
      let d = dist((x, y), (p.x, p.y))
      //t[x][y] += d
      t += d
      if d < mindist {
        mindist = d
        minid = p.id
      } else if d == mindist {
        minid = 0
      }
    }
    m[x][y] = minid
    if t < 10000 {
      tmax += 1
    }
  }
}

var a = [Int:Int]()
var o = Set<Int>()

positions.forEach {
  a[$0.id] = 0
}

for y in 0...my {
  //var l = ""
  for x in 0...mx {
    //l += "\(t[x][y])  "
    let id = m[x][y]
    if id != 0 {
      a[id]! += 1
      if x == 0 || y == 0 || x == mx || y == my {
        o.insert(m[x][y])
      }
    }
  }
  //print(l)
}

var maxa = 0
a.forEach {
  if !o.contains($0.key) {
    maxa = max(maxa, $0.value)
  }
}

print(maxa)
print(tmax)
