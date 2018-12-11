import Foundation

let size = 300
let sn = 1718

var grid = [[Int]](repeating: [Int](repeating: 0, count: size), count: size)

for y in 0..<size {
  for x in 0..<size {
    grid[x][y] = (((x + 10) * y + sn) * (x + 10) / 100) % 10 - 5
  }
}

var m = Int.min
var mx = 0
var my = 0
var ms = 0

var m3 = Int.min
var m3x = 0
var m3y = 0

for y in 0..<size {
  for x in 0..<size {
    var s = 0
    var sum = 0
    while x + s < size && y + s < size {
      for i in 0...s {
        sum += grid[x + s][y + i]
      }
      for i in 0..<s {
        sum += grid[x + i][y + s]
      }
      s += 1
      if s == 3 && sum > m3 {
        m3x = x
        m3y = y
        m3 = sum
      }
      if sum > m {
        mx = x
        my = y
        ms = s
        m = sum
      }
    }
  }
}

print("\(m3x),\(m3y)")
print("\(mx),\(my),\(ms)")


