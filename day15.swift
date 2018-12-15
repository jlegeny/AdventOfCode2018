import Foundation

let path = URL(fileURLWithPath: "input-day15-test.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

let col_g = "\u{001B}[0;34m"
let col_r = "\u{001B}[0;31m"
let col_0 = "\u{001B}[0;39m"


enum Tile {
  case none
  case wall
  case goblin(hp: Int)
  case elf(hp: Int)
}

var imap = [[Tile]](repeating: [Tile](repeating: .none, count: lines.count - 1), count: lines.first!.count) 

do {
  var y = 0
  lines.dropLast().forEach {
    var x = 0
    for t in $0 {
      switch (t) {
      case ".":
        imap[x][y] = .none
      case "#":
        imap[x][y] = .wall
      case "E":
        imap[x][y] = .elf(hp: 200)
      case "G":
        imap[x][y] = .goblin(hp: 200)
      default:
        fatalError("invalid map")
      }
      x += 1
    }
    y += 1
  }
}

func printmap(map: [[Tile]], clear: Bool = false) {
  var l = clear ? "\u{001B}[2J" : ""
  for y in 0..<map.first!.count {
    var lhp = ""
    for x in 0..<map.count {
      switch (map[x][y]) {
      case .none:
        l += " "
      case .wall:
        l += "#"
      case .elf(let hp):
        l += "\(col_g)E\(col_0)"
        lhp += " \(col_g)\(hp)\(col_0)"
      case .goblin(let hp):
        l += "\(col_r)G\(col_0)"
        lhp += " \(col_r)\(hp)\(col_0)"
      }
    }
    l += lhp + "\n"
  }
  print(l)
}

func attack(map: inout [[Tile]], _ x: Int, _ y: Int, _ force: Int = 3) -> Bool {
  var ax = Int.max
  var ay = Int.max
  var mhp = Int.max
  var next: Tile? = nil
  var elfDied = false
  for d in [(0, -1), (-1, 0), (1, 0), (0, 1)] {
    switch (map[x][y], map[x + d.0][y + d.1]) {
    case (.goblin, .elf(let hp)):
      if hp < mhp {
        (ax, ay) = (x + d.0, y + d.1)
        mhp = hp
        if hp > 3 {
          next = .elf(hp: hp - 3)
        } else {
          next = Tile.none
          elfDied = true
        }
      }
    case (.elf, .goblin(let hp)):
      if hp < mhp {
        (ax, ay) = (x + d.0, y + d.1)
        mhp = hp
        next = hp > force ? .goblin(hp: hp - force) : Tile.none
      }
    case (_, _):
      break
    }
  }
  if let n = next {
    map[ax][ay] = n
  }
  return elfDied
}

struct Node : Hashable, CustomStringConvertible {
  let x: Int
  let y: Int
  var description: String {
    return "Node(\(x), \(y))"
  }
}

func move(_ map: inout [[Tile]], _ x: Int, _ y: Int) -> Node? {
  for (nx, ny) in [(x, y - 1), (x - 1, y), (x + 1, y), (x, y + 1)] {
    switch (map[x][y], map[nx][ny]) {
    case (.goblin, .elf):
      fallthrough
    case (.elf, .goblin):
      return Node(x: x, y: y)
    default:
      break
    }
  }

  var unvisited = Set<Node>()
  var targets = Set<Node>()

  var dist = [[Int]](repeating: [Int](repeating: -1, count: map.count), count: map.first!.count) 
  var path = [[[Node]]](repeating: [[Node]](repeating: [], count: map.count), count: map.first!.count) 

  for my in 0..<map.first!.count {
    for mx in 0..<map.count {
      switch (map[x][y], map[mx][my]) {
      case (_, .none):
        if mx != x || my != y {
          dist[mx][my] = Int.max
          unvisited.insert(Node(x: mx, y: my))
        }
      case (.goblin, .elf):
        fallthrough
      case (.elf, .goblin):
        for (nx, ny) in [(mx, my - 1), (mx - 1, my), (mx + 1, my), (mx, my + 1)] {
          switch (map[nx][ny]) {
          case .none:
            if mx != x || my != y {
              targets.insert(Node(x: nx, y: ny))
            }
          default:
            break
          }
        }
      case (_, _):
        break
      }
    }
  }
  dist[x][y] = 0

  var cx = x
  var cy = y
  repeat {
    unvisited.remove(Node(x: cx, y: cy))
    for (mx, my) in [(cx, cy - 1), (cx - 1, cy), (cx + 1, cy), (cx, cy + 1)] {
      if dist[mx][my] != -1 {
        if dist[cx][cy] + 1 < dist[mx][my] {
          dist[mx][my] = dist[cx][cy] + 1
          path[mx][my] = path[cx][cy] + [Node(x: cx, y: cy)]
        }
      }
    }

    var minx = 0
    var miny = 0
    var mind = Int.max
    #if PRINT_PATHFINDING
    var ld = ""
    #endif
    for my in 0..<dist.first!.count {
      for mx in 0..<dist.count {
        #if PRINT_PATHFINDING
        var colored = true
        if cx == mx && cy == my {
          ld += col_g
        } else if targets.contains(Node(x: mx, y: my)) {
          ld += col_r
        } else {
          colored = false
        }
        #endif
        if unvisited.contains(Node(x: mx, y: my)) {
          let d = dist[mx][my]
          if d < mind || (d == mind && (my < miny || (my == miny && mx < minx))) {
            (minx, miny, mind) = (mx, my, d)
          }
          #if PRINT_PATHFINDING
          ld += d == Int.max ? "X" : "\(d)"
          #endif
        } else {
          #if PRINT_PATHFINDING
          ld += dist[mx][my] == -1 ? "." : "\(dist[mx][my])"
          #endif
        }
        #if PRINT_PATHFINDING
        if colored {
          ld += col_0
        }
        #endif
      }
      #if PRINT_PATHFINDING
      ld += "\n"
      #endif
    }
    #if PRINT_PATHFINDING
    print(ld)
    let _ = readLine()
    #endif

    if mind == Int.max {
      return nil
    }

    (cx, cy) = (minx, miny)

  } while !targets.contains(Node(x: cx, y: cy))

  switch (map[cx][cy]) {
  case .none:
    path[cx][cy].append(Node(x: cx, y: cy))
  default:
    break
  }
  return path[cx][cy].dropFirst().first
}


func action(map: inout [[Tile]], _ x: Int, _ y: Int, _ force: Int) -> (Bool, Node) {

  var (nx, ny) = (x, y)
  if let m = move(&map, x, y) {
    map[m.x][m.y] = map[x][y]
    if x != m.x || y != m.y {
      map[x][y] = .none
    }
    (nx, ny) = (m.x, m.y)
  }
  let elfDied = attack(map: &map, nx, ny, force)
  return (elfDied, Node(x: nx, y: ny))
}

func round(map: inout [[Tile]], force: Int = 3) -> (Bool, Int) {
  var done = Set<Node>()
  var elves = 0
  var goblins = 0
  for y in 0..<map.first!.count {
    for x in 0..<map.count {
      if done.contains(Node(x: x, y: y)) {
        continue
      }
      switch (map[x][y]) {
      case .elf(let hp):
        elves += hp
        done.insert(action(map: &map, x, y, force).1)
      case .goblin(let hp):
        goblins += hp
        let result = action(map: &map, x, y, force)
        done.insert(result.1)
        if result.0 && force != 3 {
          return (false, -1)
        }
      default:
        break
      }
    }
  }
  return (elves > 0 && goblins > 0, max(elves, goblins))
}

do {
  var map = imap
  print("Turn \(0)")
  printmap(map: map)
  var turn = 0
  repeat {
    let result = round(map: &map)
    if (!result.0) {
      print(result.1)
      break
    }
    turn += 1
    #if PRINT_TURNS
    let _ = readLine()
    print("Turn \(turn)")
    printmap(map: map)
    #endif
  } while true
  print("Turn \(turn)")
  printmap(map: map)
}

var force = 15
var dead = false
repeat {
  force += 1
  var map = imap
  var turn = 0
  dead = false
  inner: repeat {
    let result = round(map: &map, force: force)
    if !result.0 {
      if result.1 == -1 {
        dead = true
      } else {
        print("Turn \(turn), \(result.1), force \(force)")
      }
      break inner
    }
    turn += 1
  } while true
} while dead


