import Foundation

let path = URL(fileURLWithPath: "input-day17.txt")
//let path = URL(fileURLWithPath: "input-day17-test.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

let col_g = "\u{001B}[0;34m"
let col_r = "\u{001B}[0;31m"
let col_0 = "\u{001B}[0;39m"

var input = [[Int]]()

var minx = Int.max
var maxx = Int.min
var miny = Int.max
var maxy = Int.min

do {
  let cset = CharacterSet.decimalDigits.union(["-"]).inverted.subtracting(CharacterSet.newlines)
  let dots = CharacterSet(["."])
  let yset = CharacterSet(["y", "="])

  lines.dropLast().forEach {
    let scanner = Scanner(string: $0)
    var i = [Int](repeating: 0, count: 4)
    var c = 0
    if scanner.scanCharacters(from: yset, into: nil) {
      c = 2
    } else {
      scanner.scanCharacters(from: cset, into: nil)
    }
    scanner.scanInt(&i[c])
    if scanner.scanCharacters(from: dots, into: nil) {
      scanner.scanInt(&i[c+1])
    } else {
      i[c+1] = i[c]
    }
    scanner.scanCharacters(from: cset, into: nil)
    c += 2
    c %= 4
    scanner.scanInt(&i[c])
    if scanner.scanCharacters(from: dots, into: nil) {
      scanner.scanInt(&i[c+1])
    } else {
      i[c+1] = i[c]
    }
    minx = min(minx, i[0])
    maxx = max(maxx, i[1])
    miny = min(miny, i[2])
    maxy = max(maxy, i[3])
    input.append(i)
  }
}

maxx += 10
minx -= 10

var m = [[Int]](repeating: [Int](repeating: 0, count: maxy - miny + 1), count: maxx - minx + 1)
var w = [[Bool]](repeating: [Bool](repeating: false, count: maxy - miny + 1), count: maxx - minx + 1)

input.forEach {
  for x in $0[0] - minx ... $0[1] - minx {
    for y in $0[2] - miny ... $0[3] - miny {
      m[x][y] = 1
    }
  }
}

class Source : Hashable {
  var x = 0
  var y = 0
  var left = true
  var right = true
  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }
}

extension Source: Equatable {
  static func == (lhs: Source, rhs: Source) -> Bool {
    return lhs.x == rhs.x &&
      lhs.y == rhs.y
  }
}

class Drop {
  var x: Int
  var y: Int
  var falling: Bool = true
  var dx: Int = 0
  var dead: Bool = false
  var source: Source
  var impactWater: Bool
  init (x: Int, y: Int, source: Source, falling: Bool = true, dx: Int = 0, iw: Bool = false) {
    self.x = x
    self.y = y
    self.source = source
    self.falling = falling
    self.dx = dx
    self.impactWater = iw
  }
}

func printm(_ m: [[Int]], _ drops: [Drop] = [], _ ty: Int = 0, _ by: Int = Int.max) {
  var l = ""
  for y in max(ty, 0)..<min(maxy-miny+1, by) {
    xloop: for x in 0..<maxx-minx+1 {
      for d in drops {
        if d.x == x && d.y == y {
          l += col_r
          l += d.falling ? "v" : (d.dx < 0 ? "<" : ">")
          l += col_0
          continue xloop
        }
      }
      switch (m[x][y]) {
      case 0:
        l += w[x][y] ? "\(col_g)o\(col_0)" : " "
      case 1:
        l += "#"
      case 2:
        l += w[x][y] ? "\(col_g)~\(col_0)" : "~"
      default:
        l += "?"
      }
    }
    l += "\n"
  }
  print(l)
}

var sources = Set<Source>() 
sources.insert(Source(x: 500-minx, y: 0))

func cycle(_ m: inout [[Int]]) -> Bool {
  var drops: [Drop] = []
  //sources.filter({ $0.left || $0.right }).forEach {
  sources.forEach {
    drops.append(Drop(x: $0.x, y: $0.y, source: $0))
  }

  var deepy = 0
  var bottom = false
  loop: repeat {

    droploop: for d in drops {
      w[d.x][d.y] = true
      if d.y == maxy - 1 {
        d.dead = true
        bottom = true
        continue droploop
      }

      if d.falling {
        while m[d.x][d.y + 1] == 0 {
          d.y += 1
          w[d.x][d.y] = true
          deepy = max(deepy, d.y)
          if d.y == maxy - 1{
            d.dead = true
            bottom = true
            continue droploop
          }
        }

        d.dead = true
//        if m[d.x - 1][d.y] == 0 {
          drops.append(Drop(x: d.x, y: d.y, source: d.source, falling: false, dx: -1, iw: m[d.x][d.y + 1] == 2))
//        }
        if m[d.x + 1][d.y] == 0 {
          drops.append(Drop(x: d.x, y: d.y, source: d.source, falling: false, dx: +1, iw: m[d.x][d.y + 1] == 2))
        }
        if m[d.x - 1][d.y] != 0 && m[d.x + 1][d.y] != 0 {
          m[d.x][d.y] = 2
        }

        continue droploop
      }

      if !d.falling {
        while m[d.x + d.dx][d.y] == 0 && m[d.x][d.y + 1] != 0 {
          d.x += d.dx
          w[d.x][d.y] = true
        }
        if m[d.x][d.y + 1] == 0 {
          d.dead = true
          if d.impactWater {
            if d.dx > 0 {
              d.source.right = false
            } else {
              d.source.left = false
            }
          }
          sources.insert(Source(x: d.x, y: d.y))
          continue droploop
        } else {
          if d.dx == -1 {
            var needsFill = false
            for tx in d.x...maxx {
              w[d.x][d.y] = true
              if m[tx][d.y + 1] == 0 {
                d.source.right = false
                break
              }
              if m[tx][d.y] != 0 {
                needsFill = true
                break
              }
            }
            if needsFill {
              var tx = d.x
              while m[tx][d.y] == 0 {
                w[tx][d.y] = true
                m[tx][d.y] = 2
                tx += 1
              }
            }
            d.dead = true
            continue droploop
          }

          d.dead = true
          continue droploop
        }
      }
    }
    if deepy > 1779 {
      printm(m, drops, deepy - 20, deepy + 60)
      print(drops.filter({!$0.dead}).map { "\($0.x) \($0.y) \($0.falling) \($0.dx)"})
      let _ = readLine()
    }
    drops = drops.filter({ !$0.dead })
  } while !drops.isEmpty

  print(sources.filter({ $0.right || $0.left }).count, sources.count, deepy, "/", maxy)
  return bottom
}

//printm(m)
repeat {
  if cycle(&m) {
    break
  }

   //printm(m)
   //let _ = readLine()
} while true
printm(m)


print(w.reduce(0, { (sum, row) in sum + row.reduce(0, { $0 + ($1 ? 1 : 0) }) }))
print(m.reduce(0, { (sum, row) in sum + row.reduce(0, { $0 + ($1 == 2 ? 1 : 0) }) }))
