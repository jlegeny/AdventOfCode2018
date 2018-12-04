import Foundation

let path = URL(fileURLWithPath: "input-day3.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

struct Claim {
	var id: Int = 0
  var x: Int = 0
  var y: Int = 0
  var w: Int = 0
  var h: Int = 0
}

var claims: [Claim] = []

var mx = 0
var my = 0

lines.forEach {
  var c = Claim()
  let scanner = Scanner(string: $0)
  // #1 @ 662,777: 18x27
  scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
  scanner.scanInt(&c.id)
  scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
  scanner.scanInt(&c.x)
  scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
  scanner.scanInt(&c.y)
  scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
  scanner.scanInt(&c.w)
  scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
  scanner.scanInt(&c.h)
  mx = max(mx, c.x + c.w)
  my = max(my, c.y + c.h)
  claims.append(c)
}

print("\(mx) \(my)")
var quilt = [[Int]](repeating: [Int](repeating: 0, count: my), count: mx)
var quarrels = 0
claims.forEach {
  for x in $0.x..<$0.x + $0.w {
    for y in $0.y..<$0.y + $0.h {
      if quilt[x][y] == 0 {
        quilt[x][y] = $0.id
      } else if quilt[x][y] > 0 {
        quilt[x][y] = -1
        quarrels += 1
      }
    }
  }
}

print("\(quarrels)")
for c in claims {
	var valid = true
  inner: for x in c.x..<c.x + c.w {
    for y in c.y..<c.y + c.h {
      if quilt[x][y] != c.id {
				valid = false
				break inner
      }
    }
  }
	if valid {
		print(c.id)
		break
	}
}


