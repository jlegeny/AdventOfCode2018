import Foundation

let path = URL(fileURLWithPath: "input-day16.txt")

guard let input = (try? String(contentsOf: path)) else {
  fatalError("failed to read \(path)")
}

struct TestCase {
  var before = [Int](repeating: 0, count: 4)
  var after = [Int](repeating: 0, count: 4)
  var instruction = [Int](repeating: 0, count: 4)
}

var tests = [TestCase]()

var program = [[Int]]()

do {
  var t = TestCase()
  let scanner = Scanner(string: input)
  let cset = CharacterSet.decimalDigits.union(["-"]).inverted.subtracting(CharacterSet.newlines)
  while scanner.scanCharacters(from: cset, into: nil) {
    for i in 0..<4 {
      scanner.scanInt(&t.before[i])
      scanner.scanCharacters(from: cset, into: nil)
    }
    scanner.scanCharacters(from: CharacterSet.newlines, into: nil)
    for i in 0..<4 {
      scanner.scanInt(&t.instruction[i])
      scanner.scanCharacters(from: cset, into: nil)
    }
    scanner.scanCharacters(from: CharacterSet.newlines, into: nil)
    for i in 0..<4 {
      scanner.scanInt(&t.after[i])
      scanner.scanCharacters(from: cset, into: nil)
    }
    scanner.scanCharacters(from: CharacterSet.newlines, into: nil)
    tests.append(t)
  }

  loop: repeat {
    var inst = [Int](repeating: 0, count: 4)
    for i in 0..<4 {
      if !scanner.scanInt(&inst[i]) {
        break loop
      }
      scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted, into: nil)
    }
    program.append(inst)
  } while true
}

enum Inst: CaseIterable {
  case addr
  case addi
  case mulr
  case muli
  case banr
  case bani
  case borr
  case bori
  case setr
  case seti
  case gtir
  case gtri
  case gtrr
  case eqir
  case eqri
  case eqrr
}

func execute(_ i: Inst, _ p: [Int], on reg: [Int]) -> [Int] {
  let (a, b, c) = (p[0], p[1], p[2])
  var r = reg
  switch (i) {
  case .addr:
    r[c] = reg[a] + reg[b]
  case .addi:
    r[c] = reg[a] + b
  case .mulr:
    r[c] = reg[a] * reg[b]
  case .muli:
    r[c] = reg[a] * b
  case .banr:
    r[c] = reg[a] & reg[b]
  case .bani:
    r[c] = reg[a] & b
  case .borr:
    r[c] = reg[a] | reg[b]
  case .bori:
    r[c] = reg[a] | b
  case .setr:
    r[c] = r[a]
  case .seti:
    r[c] = a
  case .gtir:
    r[c] = a > r[b] ? 1 : 0
  case .gtri:
    r[c] = r[a] > b ? 1 : 0
  case .gtrr:
    r[c] = r[a] > r[b] ? 1 : 0
  case .eqir:
    r[c] = a == r[b] ? 1 : 0
  case .eqri:
    r[c] = r[a] == b ? 1 : 0
  case .eqrr:
    r[c] = r[a] == r[b] ? 1 : 0
  }
  return r
}


// print(tests)

var corr = [Int:Set<Inst>]()

var more3 = 0
tests.forEach {
  t in
  let i0 = t.instruction[0]
  let p = [Int](t.instruction[1...3])

  if corr[i0] == nil {
    corr[i0] = Set<Inst>()
  }
  var s = 0
  for inst in Inst.allCases {
    if execute(inst, p, on: t.before) == t.after {
      corr[i0]!.insert(inst)
      s += 1
    }
  }
  if s >= 3 {
    more3 += 1
  }
}

print(more3)

var fcorr = [Int:Inst]()

repeat {
  guard let lone = corr.first(where: { $1.count == 1 }) else {
    break
  }
  fcorr[lone.key] = lone.value.first!
  
  corr = corr.mapValues { $0.subtracting(lone.value) }
  
} while true

print(fcorr)

do {
  var reg = [0, 0, 0, 0]

  for i in program {
    reg = execute(fcorr[i[0]]!, [Int](i[1...3]), on: reg)
  }

print(reg)
}

