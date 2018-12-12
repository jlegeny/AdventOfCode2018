import Foundation

let path = URL(fileURLWithPath: "input-day12.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

var pots = [Bool]()
var patterns = [[Bool]]()

do {
  let scanner = Scanner(string: lines.first!)
  scanner.charactersToBeSkipped = CharacterSet(["#", "."]).inverted

  var s: NSString? = " "
  scanner.scanCharacters(from: ["#", "."], into: &s)
  pots = String(s!).map { $0 == "#" }
}

lines.dropFirst().dropFirst().dropLast().forEach {
  let scanner = Scanner(string: $0)
  scanner.charactersToBeSkipped = CharacterSet(["#", "."]).inverted
  var p: NSString? = " "
  scanner.scanCharacters(from: ["#", "."], into: &p)
  var r: NSString? = " "
  scanner.scanCharacters(from: ["#", "."], into: &r)
  let pattern: [Bool] = String(p!).map { $0 == "#" }
  if r == "#" {
    patterns.append(pattern)
  }
}

pots = [false, false, false, false] + pots + [false, false, false, false]
var first = -4

let generations = 20

var gen = 1
var direction = 1
while true {
  var next = [Bool](repeating: false, count: pots.count + 8)
  for i in 2..<pots.count - 2 {
    loop_patterns: for p in patterns {
      for j in -2...2 {
        if p[j + 2] != pots[i + j] {
          continue loop_patterns
        }
      }
      next[i+4] = true
    }
  }

  let fnext = next.firstIndex(of: true)!
  let lnext = next.lastIndex(of: true)!

  next = [Bool](next[fnext-4...lnext+4])
  if pots == next {
    direction = first - fnext + 4
    break
  }
  first += (fnext - 8)

  pots = next
  if gen == 20 {
    var sum = 0
    for i in 0..<pots.count {
      if pots[i] {
        sum += first + i
      }
    }
    print(sum)
  }
  gen += 1
}

first += (50_000_000_000 - gen + 1)

var sum = 0
for i in 0..<pots.count {
  if pots[i] {
    sum += first + i
  }
}
print(sum)
