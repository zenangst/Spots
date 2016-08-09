import Foundation

extension NSTimeInterval {

  var minutesAndSeconds: String {
    return String(format:"%d:%02ld",
                  Int(self / 60.0) / 1000,
                  Int(self / 1000 % 60))
  }
}
