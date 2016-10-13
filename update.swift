#!/usr/bin/env xcrun swift

import Foundation

struct System {

  static func execute(command: String, _ arguments: String = "") {
    guard let command = which(command: command) else { return }
    task(command: command, arguments)
  }

  private static func which(command: String, _ arguments: String? = nil) -> String? {
    let task = Process()
    task.launchPath = "/usr/bin/which"
    task.arguments = [command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?

    return output?.components(separatedBy: "\n").first
  }

  private static func task(command: String, _ arguments: String? = nil) {
    let task = Process()
    task.launchPath = command

    if let arguments = arguments, !arguments.isEmpty {
      task.arguments = arguments.components(separatedBy: " ")
    }

    let stdOut = Pipe()
    task.standardOutput = stdOut
    let stdErr = Pipe()
    task.standardError = stdErr

    let handler =  { (file: FileHandle!) -> Void in
      let data = file.availableData
      guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        else { return}

      print(output.components(separatedBy: "\n").first!)
    }

    stdErr.fileHandleForReading.readabilityHandler = handler
    stdOut.fileHandleForReading.readabilityHandler = handler

    task.terminationHandler = { (task: Process?) -> () in
      stdErr.fileHandleForReading.readabilityHandler = nil
      stdOut.fileHandleForReading.readabilityHandler = nil
    }

    task.launch()
    task.waitUntilExit()
  }
}

if let rootPath = ProcessInfo.processInfo.environment["PWD"] {
  var error: NSError? = nil
  do {
    let directories = try FileManager().contentsOfDirectory(atPath: "\(rootPath)/Examples")
    for directory in directories where directory.characters.first != "." {
      var isDir : ObjCBool = false
      FileManager().changeCurrentDirectoryPath("\(rootPath)/Examples/\(directory)")
      System.execute(command: "pod", "update --no-repo-update")
    }
  } catch {}
}
