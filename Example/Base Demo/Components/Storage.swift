import UIKit

public struct Storage {

  // MARK: - File system

  static var fileManager: NSFileManager = {
    let manager = NSFileManager.defaultManager()
    return manager
    }()

  public static let applicationDirectory: String = {
    let paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    let basePath: AnyObject? = (paths.count > 0) ? paths.firstObject : nil
    return basePath as! String;
  }()

  private static func buildPath(path: URLStringConvertible, createPath: Bool = false) -> String {
    var buildPath = path.string
    if path.string != Storage.applicationDirectory {
      buildPath = "\(Storage.applicationDirectory)/\(path.string)"

      let folderPath = NSString(string: buildPath).stringByDeletingLastPathComponent

      if folderPath != Storage.applicationDirectory {
        do {
          try fileManager.createDirectoryAtPath(folderPath,
            withIntermediateDirectories: true,
            attributes: nil)
        } catch { }
      }
    }

    return buildPath
  }

  // MARK: - Loading

  public static func load(path: URLStringConvertible) -> AnyObject? {
    let loadPath = Storage.buildPath(path)
    return fileManager.fileExistsAtPath(loadPath)
      ? NSKeyedUnarchiver.unarchiveObjectWithFile(loadPath)
      : nil
  }

  public static func load(contentsAtPath path: URLStringConvertible, _ error: NSErrorPointer? = nil) -> String? {
    let loadPath = Storage.buildPath(path)
    let contents: NSString?
    do {
      contents = try NSString(contentsOfFile: loadPath,
            encoding: NSUTF8StringEncoding)
    } catch { contents = nil }

    return contents as? String
  }

  public static func load(dataAtPath path: URLStringConvertible) -> NSData? {
    let loadPath = Storage.buildPath(path)
    return fileManager.fileExistsAtPath(loadPath)
      ? NSData(contentsOfFile: loadPath)
      : nil
  }

  public static func load(JSONAtPath path: URLStringConvertible) -> AnyObject? {
    var object: AnyObject?

    if let data = load(dataAtPath: path) {
      do {
        object = try NSJSONSerialization.JSONObjectWithData(data,
          options: .MutableContainers)
      } catch _ {
        object = nil
      }
    }

    return object
  }

  // MARK: - Saving

  public static func save(object  object: AnyObject, _ path: URLStringConvertible = Storage.applicationDirectory, closure: (error: NSError?) -> Void) {
    let savePath = Storage.buildPath(path, createPath: true)
    let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(object)
    var error: NSError?

    do {
      try data.writeToFile(savePath,
        options: NSDataWritingOptions.DataWritingAtomic)
    } catch let error1 as NSError {
      error = error1
    }

    closure(error: error)
  }

  public static func save(contents  contents: String, _ path: URLStringConvertible = Storage.applicationDirectory, closure: (error: NSError?) -> Void) {
    let savePath = Storage.buildPath(path, createPath: true)
    var error: NSError?

    do {
      try (contents as NSString).writeToFile(savePath, atomically: true, encoding: NSUTF8StringEncoding)
    } catch let error1 as NSError {
      error = error1
    }

    closure(error: error)
  }

  public static func save(data  data: NSData, _ path: URLStringConvertible = Storage.applicationDirectory, closure: (error: NSError?) -> Void) {
    let savePath = Storage.buildPath(path, createPath: true)
    var error: NSError?

    do {
      try data.writeToFile(savePath, options: .DataWritingAtomic)
    } catch let error1 as NSError {
      error = error1
    }

    closure(error: error)
  }

  public static func save(JSON  JSON: AnyObject, _ path: URLStringConvertible = Storage.applicationDirectory, closure: (error: NSError?) -> Void) {
    var error: NSError?

    do {
      let data = try NSJSONSerialization.dataWithJSONObject(JSON,
        options: [])
        save(data: data, path, closure: closure)
    } catch let error1 as NSError {
      error = error1
      closure(error: error)
    }
  }

  // MARK: - Helper Methods

  public static func existsAtPath(path: URLStringConvertible) -> Bool {
    let loadPath = Storage.buildPath(path)
    return fileManager.fileExistsAtPath(loadPath)
  }

  public static func removeAtPath(path: URLStringConvertible, _ error: NSErrorPointer? = nil) {
    let loadPath = Storage.buildPath(path)

    do {
      try fileManager.removeItemAtPath(loadPath)
    } catch { }
  }
}

public protocol URLStringConvertible {
  var url: NSURL { get }
  var string: String { get }
}

extension String: URLStringConvertible {

  public var url: NSURL {
    let aURL = NSURL(string: self)!
    return aURL
  }

  public var string: String {
    return self
  }
}
