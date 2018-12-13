import Foundation

let path = URL(fileURLWithPath: "input-day13.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

enum Tile {
  case none
  case vertical
  case horizontal
  case rise
  case fall
  case cross
}

class Cart : Hashable, Equatable {
  var id = 0
  var x = 0
  var y = 0
  var dx = 0
  var dy = 0
  var turn = 0
  init(id: Int, x: Int, y: Int, dx: Int, dy: Int) {
    self.id = id
    self.x = x
    self.y = y
    self.dx = dx
    self.dy = dy
  }
  var hashValue : Int {
    get {
      return self.id
    }
  }
}

func == (lhs: Cart, rhs: Cart) -> Bool {
    return lhs.id == rhs.id
}

var map =  [[Tile]](repeating: [Tile](repeating: .none, count: lines.count - 1), count: lines.first!.count) 
var carts = [Cart]()

let parser: [Character:Tile] = [
  " " : .none,
  "|" : .vertical,
  "-" : .horizontal,
  "/" : .rise,
  "\\" : .fall,
  "+" : .cross,
  "^" : .vertical,
  "v" : .vertical,
  ">" : .horizontal,
  "<" : .horizontal
]

var y = 0
var id = 1
lines.dropLast().forEach {
  var x = 0
  for t in $0 {
    map[x][y] = parser[t]!

    let cart: Cart?
    switch (t) {
    case ">":
      cart = Cart(id: id, x: x, y: y, dx: 1, dy: 0)
    case "v":
      cart = Cart(id: id, x: x, y: y, dx: 0, dy: 1)
    case "<":
      cart = Cart(id: id, x: x, y: y, dx: -1, dy: 0)
    case "^":
      cart = Cart(id: id, x: x, y: y, dx: 0, dy: -1)
    default:
      cart = nil
    }
    if let c = cart {
      carts.append(c)
      id += 1
    }
    x += 1
  }
  y += 1
}


let printer: [Tile:String] = [
  .none : " ",
  .vertical : "|",
  .horizontal : "-",
  .rise : "/",
  .fall : "\\",
  .cross : "+"
]


func rotate(rot: Int, dx: Int, dy: Int) -> (Int, Int) {
  if rot == 0 {
    return (dy, -dx)
  } else if rot == 1 {
    return (dx, dy)
  } else if rot == 2 {
    return (-dy, dx)
  }
  return (0, 0)
}

func printmap() {
  var l = "\u{001B}[2J"
  for y in 0..<map.first!.count {
    for x in 0..<map.count {
      var hasCart = false
      carts.forEach {
        if $0.x == x && $0.y == y {
          l += "\u{001B}[0;31m"
          l += $0.dx != 0 ? ($0.dx > 0 ? ">" : "<") : ($0.dy > 0 ? "v" : "^")
          l += "\u{001B}[0;39m"
          hasCart = true
        }
      }
      if !hasCart {
        l += map[x][y] != .none ? printer[map[x][y]]! : " "
      }

    }
    l += "\n"
  }
  print(l)
}

outerloop: while true {

  carts.sort(by: { return $0.y < $1.y || $0.x < $1.x })
  carts.forEach {
    let nx = $0.x + $0.dx
    let ny = $0.y + $0.dy
    var ndx = 0
    var ndy = 0
    switch (map[nx][ny]) {
    case .vertical:
      ndx = 0
      ndy = ny > $0.y ? 1 : -1
    case .horizontal:
      ndx = nx > $0.x ? 1 : -1
      ndy = 0
    case .rise:
      ndx = ny < $0.y ? 1 : (ny > $0.y ? -1 : 0)
      ndy = nx < $0.x ? 1 : (nx > $0.x ? -1 : 0)
    case .fall:
      ndx = ny < $0.y ? -1 : (ny > $0.y ? 1 : 0)
      ndy = nx < $0.x ? -1 : (nx > $0.x ? 1 : 0)
    case .cross:
      (ndx, ndy) = rotate(rot: $0.turn, dx: $0.dx, dy: $0.dy)
      $0.turn += 1
      $0.turn %= 3
    case .none:
      fatalError("Derailed at \(nx), \(ny)")
    }
    $0.x = nx
    $0.y = ny
    $0.dx = ndx
    $0.dy = ndy

    var tbr = Set<Cart>()
    for c in carts {
      if c.id != $0.id && c.x == $0.x && c.y == $0.y {
        print("\(c.x),\($0.y)")
        tbr.insert(c)
        tbr.insert($0)
      }
    }
    carts.removeAll(where: { tbr.contains($0) })
 
  }

  if carts.count == 1 {
    let c = carts.first!
    print("\(c.x),\(c.y)")
    break outerloop
  }
}
