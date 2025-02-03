import os

enum Logger {
    static func error(_ message: String) {
        os_log("%{public}@", type: .error, message)
    }
}
