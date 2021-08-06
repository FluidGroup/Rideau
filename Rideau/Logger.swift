import UIKit
import os.log

enum Log {

  static func debug(_ log: OSLog, _ object: Any...) {
    if #available(iOS 12.0, *) {
      os_log(.debug, log: log, "%@", object.map { "\($0)" }.joined(separator: " "))
    }
  }

  static func error(_ log: OSLog, _ object: Any...) {
    if #available(iOS 12.0, *) {
      os_log(.error, log: log, "%@", object.map { "\($0)" }.joined(separator: " "))
    }
  }

}

extension OSLog {

  static let pan: OSLog = {
    #if DEBUG
    return OSLog.init(subsystem: "Rideau", category: "👆pan")
    #else
    return .disabled
    #endif
  }()

  static let scrollView: OSLog = {
    #if DEBUG
    return OSLog.init(subsystem: "Rideau", category: "🎞 ScrollView")
    #else
    return .disabled
    #endif
  }()
}
