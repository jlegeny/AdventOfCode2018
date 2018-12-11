import Foundation

let path = URL(fileURLWithPath: "input-day9-test.txt")

guard let input = (try? String(contentsOf: path)) else {
  fatalError("failed to read \(path)")
}

var playerCount = 0
var lastMarble = 0

let scanner = Scanner(string: input)
scanner.scanInt(&playerCount)
scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
scanner.scanInt(&lastMarble)

class Marble {
  let score: Int
  var right: Marble!
  var left: Marble!
  init() {
    self.score = 0
    self.right = self
    self.left = self
  }
  init(score: Int, right: Marble, left: Marble) {
    self.score = score
    self.right = right
    self.left = left
  }
}

func insert(score: Int, current: inout Marble) -> Int {
  if score % 23 != 0 {
    let after = current.right!
    let before = current.right.right!
    current = Marble(score: score, right: before, left: after)
    after.right = current
    before.left = current
    return 0
  } else {
    let remove = current.left.left.left.left.left.left.left!
    remove.left.right = remove.right
    remove.right.left = remove.left
    current = remove.right
    return score + remove.score
  }
}

var players = [Int](repeating: 0, count: playerCount)
var current = Marble()

var cm = 1
repeat {
  players[cm % playerCount] += insert(score: cm, current: &current)
  cm += 1
} while cm != lastMarble

print(players.reduce(0, max))

repeat {
  players[cm % playerCount] += insert(score: cm, current: &current)
  cm += 1
} while cm != lastMarble * 100

print(players.reduce(0, max))
