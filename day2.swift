import Foundation

let path = URL(fileURLWithPath: "input-day2.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}


var count2 = 0
var count3 = 0
lines.forEach {
  var chars = [Character:Int]()
  for c in $0 {
    if chars[c] == nil {
      chars[c] = 0
    }
    chars[c]! += 1
  }
  var has2 = false
  var has3 = false
  for c in chars {
    if c.value == 2 {
      has2 = true
    }
    if c.value == 3 {
      has3 = true
    }
    if has2 && has3 {
      break
    }
  }

  count2 += has2 ? 1 : 0
  count3 += has3 ? 1 : 0
}

print(count2)
print(count3)
print(count2 * count3)

func diff(_ a: String, _ b: String) -> Int {
  if a.count != b.count {
    return 2
  }
  var ia = a.startIndex
  var ib = b.startIndex

  var diff = 0
  repeat {
    if a[ia] != b[ib] {
      diff += 1
      if diff == 2 {
        break
      }
    }

    a.formIndex(after: &ia)
    b.formIndex(after: &ib)
  } while ia != a.endIndex

  return diff
}

func common(_ a: String, _ b: String) -> String {
  var res = ""
  var ia = a.startIndex
  var ib = b.startIndex

  repeat {
    if a[ia] == b[ib] {
      res.append(a[ia])
    }

    a.formIndex(after: &ia)
    b.formIndex(after: &ib)
  } while ia != a.endIndex

  return res
}

outer: for la in lines {
  for lb in lines {
    if diff(la, lb) == 1 {
      print(common(la, lb))
      break outer
    }
  }
}
