import Foundation

let path = URL(fileURLWithPath: "input-day19.txt")

guard let input = (try? String(contentsOf: path)) else {
  fatalError("failed to read \(path)")
}

enum Inst: String, CaseIterable {
  case addr = "addr"
  case addi = "addi"
  case mulr = "mulr"
  case muli = "muli"
  case banr = "banr"
  case bani = "bani"
  case borr = "borr"
  case bori = "bori"
  case setr = "setr"
  case seti = "seti"
  case gtir = "gtir"
  case gtri = "gtri"
  case gtrr = "gtrr"
  case eqir = "eqir"
  case eqri = "eqri"
  case eqrr = "eqrr"
}



struct Instruction {
  var opcode: Inst = .addr 
  var p = [Int](repeating: 0, count: 3)
}

var program = [Instruction]()
var regp = 0

let scanner = Scanner(string: input)
let cset = CharacterSet.decimalDigits.union(["-"]).inverted.subtracting(CharacterSet.newlines)
scanner.scanCharacters(from: cset, into: nil)
scanner.scanInt(&regp)


var sinst: NSString? = nil
while scanner.scanCharacters(from: CharacterSet.alphanumerics, into: &sinst) {
  var i = Instruction()
  i.opcode = Inst(rawValue: String(sinst!))!
  scanner.scanInt(&i.p[0])
  scanner.scanInt(&i.p[1])
  scanner.scanInt(&i.p[2])
  scanner.scanCharacters(from: CharacterSet.newlines, into: nil)
  program.append(i)
}


func execute(_ i: Inst, _ p: [Int], on r: inout [Int]) {
  let (a, b, c) = (p[0], p[1], p[2])
  switch (i) {
  case .addr:
    r[c] = r[a] + r[b]
  case .addi:
    r[c] = r[a] + b
  case .mulr:
    r[c] = r[a] * r[b]
  case .muli:
    r[c] = r[a] * b
  case .banr:
    r[c] = r[a] & r[b]
  case .bani:
    r[c] = r[a] & b
  case .borr:
    r[c] = r[a] | r[b]
  case .bori:
    r[c] = r[a] | b
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
}

do {
  var c = 0;
  var ip = 0
  var reg = [Int](repeating: 0, count: 6)
  while ip < program.count {
    c += 1;
    reg[regp] = ip
    let inst = program[ip]
    execute(inst.opcode, inst.p, on: &reg)
    ip = reg[regp]
    ip += 1
  }
  print(c, ":", reg)
}

do {
  var n = 0
  var ip = 0
  var reg = [Int](repeating: 0, count: 6)
  reg[0] = 1
  while ip < program.count {
    reg[regp] = ip
    let inst = program[ip]
    execute(inst.opcode, inst.p, on: &reg)
    ip = reg[regp]
    ip += 1
    if ip == 2 {
      n = reg[2]
      break
    }
  }

  print(n)
  var d = 1
  var r = 0
  while d * d < n {
    if n % d == 0 {
      r += d
      r += n/d
    }
    d += 1
  }
  print(r)
}

