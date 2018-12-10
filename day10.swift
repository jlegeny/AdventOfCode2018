import Foundation

let path = URL(fileURLWithPath: "input-day10.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

class Point {
  var x = 0
  var y = 0
  var vx = 0
  var vy = 0
}

var points = [Point]()

lines.dropLast().forEach {
  let p = Point()
  let scanner = Scanner(string: $0)
  let cset = CharacterSet.decimalDigits.union(["-"]).inverted
  scanner.scanCharacters(from: cset, into: nil)
  scanner.scanInt(&p.x)
  scanner.scanCharacters(from: cset, into: nil)
  scanner.scanInt(&p.y)
  scanner.scanCharacters(from: cset, into: nil)
  scanner.scanInt(&p.vx)
  scanner.scanCharacters(from: cset, into: nil)
  scanner.scanInt(&p.vy)
  points.append(p)
}

var miny = Int.min
var maxy = Int.max
var minx = Int.min
var maxx = Int.max

var cycles = 0
repeat {
  var cminy = Int.max
  var cmaxy = Int.min
  points.forEach {
    cminy = min(cminy, $0.y + $0.vy)
    cmaxy = max(cmaxy, $0.y + $0.vy)
  }
  if maxy != Int.max && cmaxy - cminy > maxy - miny {
    break
  }

  var cminx = Int.max
  var cmaxx = Int.min
  
  points.forEach {
    $0.x += $0.vx
    $0.y += $0.vy
    cminx = min(cminx, $0.x)
    cmaxx = max(cmaxx, $0.x)
  }

  miny = max(miny, cminy)
  minx = max(minx, cminx)
  maxy = min(maxy, cmaxy)
  maxx = min(maxx, cmaxx)
  cycles += 1
} while true

print(cycles)

var text = [[Bool]](repeating: [Bool](repeating: false, count: maxy - miny + 1), count: maxx - minx + 1)

points.forEach {
  text[$0.x - minx][$0.y - miny] = true
}

for y in 0..<text[0].count {
  var l = ""
  for x in 0..<text.count {
    l += text[x][y] ? "#" : "."
  }
  print(l)
}
