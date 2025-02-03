import Foundation

final class OAuth2TokenStorage {
    private init() {}
    private let key: String = "OAuth2Token"
}

// MARK: - Interface
extension OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    var token: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
