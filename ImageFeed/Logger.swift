import os

final class Logger {
    private init() {}
}

// MARK: - Interface
extension Logger {
    static let shared = Logger()
    func error(_ message: String) {
        os_log("%{public}@", type: .error, message)
    }
}
