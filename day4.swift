import Foundation

let path = URL(fileURLWithPath: "input-day4.txt")

guard let lines = (try? String(contentsOf: path))?.components(separatedBy: "\n") else {
  fatalError("failed to read \(path)")
}

struct SimpleDate : Comparable {
  let year: Int
  let month: Int
  let day: Int
  let hour: Int
  let minute: Int

  static func < (lhs: SimpleDate, rhs: SimpleDate) -> Bool {
    if lhs.year != rhs.year {
      return lhs.year < rhs.year
    } else if lhs.month != rhs.month {
      return lhs.month < rhs.month
    } else if lhs.day != rhs.day {
      return lhs.day < rhs.day
    } else if lhs.hour != rhs.hour {
      return lhs.hour < rhs.hour
    } else {
      return lhs.minute < rhs.minute
    }
  }
}

enum NoteType {
  case guardOnDuty
  case fallsAsleep
  case wakesUp
}

struct Note {
  let date: SimpleDate
  let type: NoteType
  let id: Int?
}

class Guard {
  var sleepTotal: Int = 0
  var sleepTimes = [Int](repeating: 0, count: 60)
}
var notes: [Note] = []
var guards: [Int: Guard] = [:]


let dateRegex = try! NSRegularExpression(pattern: "\\[(\\d+)-(\\d+)-(\\d+) (\\d+):(\\d+)]", options: [])

let godRegex = try! NSRegularExpression(pattern:  "Guard #(\\d+) begins shift", options: []) 

let asleepRegex = try! NSRegularExpression(pattern:  "falls asleep", options: []) 
let wokeRegex = try! NSRegularExpression(pattern:  "wakes up", options: []) 


for line in lines {
  guard let dm = dateRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)).first else {
    break
  }

  let date = SimpleDate(
    year: Int(line[Range(dm.range(at: 1), in: line)!])!,
    month: Int(line[Range(dm.range(at: 2), in: line)!])!,
    day: Int(line[Range(dm.range(at: 3), in: line)!])!,
    hour: Int(line[Range(dm.range(at: 4), in: line)!])!,
    minute: Int(line[Range(dm.range(at: 5), in: line)!])!
    )

  if let match = godRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)).first {
    let id = Int(line[Range(match.range(at: 1), in: line)!])!
    notes.append(Note(date: date, type: .guardOnDuty, id: id))
  } else if asleepRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)).first != nil {
    notes.append(Note(date: date, type: .fallsAsleep, id: nil))
  } else if wokeRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)).first != nil {
    notes.append(Note(date: date, type: .wakesUp, id: nil))
  }

}

notes.sort {
  return $0.date < $1.date
}

var currentGuard: Guard!
var asleepSince = 0
notes.forEach {
  switch ($0.type) {
  case .guardOnDuty:
    if guards[$0.id!] == nil {
      guards[$0.id!] = Guard()
    }
    currentGuard = guards[$0.id!]!
  case .fallsAsleep:
    asleepSince = $0.date.minute
  case .wakesUp:
    currentGuard.sleepTotal += $0.date.minute - asleepSince
    for m in asleepSince..<$0.date.minute {
      currentGuard.sleepTimes[m] += 1
    }
  }
}

var lazyestId = 0
var guardMaxSleep = 0
guards.forEach {
  if $0.value.sleepTotal > guardMaxSleep {
    var maxSleep = 0
    var maxMinute = 0
    for m in 0..<60 {
      if $0.value.sleepTimes[m] > maxSleep {
        maxMinute = m
        maxSleep = $0.value.sleepTimes[m]
      }
    }
    lazyestId = $0.key * maxMinute
    guardMaxSleep = $0.value.sleepTotal
  }
}

print(lazyestId)

var lazyestId2 = 0
var guardMaxMinuteSleep = 0
guards.forEach {
  var maxMinuteSleep = 0
  var maxMinute = 0
  for m in 0..<60 {
    if $0.value.sleepTimes[m] > maxMinuteSleep {
      maxMinute = m
      maxMinuteSleep = $0.value.sleepTimes[m]
    }
  }
  if maxMinuteSleep > guardMaxMinuteSleep {
    lazyestId2 = $0.key * maxMinute
    guardMaxMinuteSleep = maxMinuteSleep
  }
}

print(lazyestId2)

