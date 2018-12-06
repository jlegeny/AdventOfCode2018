import Foundation

let path = URL(fileURLWithPath: "input-day1.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}


var changes = [Int]()

lines.forEach {
  let scanner = Scanner(string: $0)
  var change = 0
  var sign: NSString?
  // #1 @ 662,777: 18x27
  if scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: &sign) {
    scanner.scanInt(&change)
    if sign == "+" {
      changes.append(change)
    } else {
      changes.append(-change)
    }
  }
}

// Part 1

var total = 0
changes.forEach {
  total += $0
}

print(total)

// Part 2

var seenFrequencies = Set<Int>()

var freq = 0
var i = 0
loop: repeat {
  if i >= changes.count {
    i = 0
  }
  freq += changes[i]
  if seenFrequencies.contains(freq) {
    break loop
  }

  seenFrequencies.insert(freq)
  i += 1
} while (true)

print(freq)
