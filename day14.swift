import Foundation

func split(_ i: UInt8) -> [UInt8] {
  if i == 0 {
    return [0]
  }
  if i < 10 {
    return [i]
  }
  return [i / 10, i % 10]
}

do {
  var r: [UInt8] = [3, 7]

  var ia = 0
  var ib = 1

  let after = 503761
  repeat {
    r += split(r[ia] + r[ib])
    ia += 1 + Int(r[ia])
    ia %= r.count
    ib += 1 + Int(r[ib])
    ib %= r.count
  } while r.count < after + 10
  print(r[after..<after+10].reduce("", { "\($0)\($1)" }))
}

do {
  var r: [UInt8] = [3, 7]

  var ia = 0
  var ib = 1

  let pattern = 503761
  let order = 1000000
  var c = 37
  repeat {
    let sum = r[ia] + r[ib]
    if sum == 0 {
      c *= 10
    } else if sum < 10 {
      c *= 10
      c += Int(sum)
    } else {
      c *= 10
      c += Int(sum / 10)
      c %= order
      if c == pattern {
        r += [0]
        break
      }
      c *= 10
      c += Int(sum % 10)
    }
    c %= order

    let s = split(sum)
    r += s
    ia += 1 + Int(r[ia])
    ia %= r.count
    ib += 1 + Int(r[ib])
    ib %= r.count

  } while c != pattern

  print(r.count - 6)
}
