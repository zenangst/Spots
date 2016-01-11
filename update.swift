#!/usr/bin/env xcrun swift

import Foundation

struct System {

  static func execute(command: String, _ arguments: String = "") {
    guard let command = which(command) else { return }
    task(command, arguments)
  }

  private static func which(command: String, _ arguments: String? = nil) -> String? {
    let task = NSTask()
    task.launchPath = "/usr/bin/which"
    task.arguments = [command]

    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: NSUTF8StringEncoding) as String?

    return output?.componentsSeparatedByString("\n").first
  }

  private static func task(command: String, _ arguments: String? = nil) {
    let task = NSTask()
    task.launchPath = command

    if let arguments = arguments where !arguments.isEmpty {
      task.arguments = arguments.componentsSeparatedByString(" ")
    }

    let stdOut = NSPipe()
    task.standardOutput = stdOut
    let stdErr = NSPipe()
    task.standardError = stdErr

    let handler =  { (file: NSFileHandle!) -> Void in
      let data = file.availableData
      guard let output = NSString(data: data, encoding: NSUTF8StringEncoding)
        else { return}

      print(output.componentsSeparatedByString("\n").first!)
    }

    stdErr.fileHandleForReading.readabilityHandler = handler
    stdOut.fileHandleForReading.readabilityHandler = handler

    task.terminationHandler = { (task: NSTask?) -> () in
      stdErr.fileHandleForReading.readabilityHandler = nil
      stdOut.fileHandleForReading.readabilityHandler = nil
    }

    task.launch()
    task.waitUntilExit()
  }
}

if let rootPath = NSProcessInfo.processInfo().environment["PWD"] {
  var error: NSError? = nil
  do {
    let directories = try NSFileManager().contentsOfDirectoryAtPath("\(rootPath)/Examples")
    for directory in directories where directory.characters.first != "." {
      var isDir : ObjCBool = false
      NSFileManager().changeCurrentDirectoryPath("\(rootPath)/Examples/\(directory)")
      System.execute("pod", "update")
    }
  } catch {}
}
