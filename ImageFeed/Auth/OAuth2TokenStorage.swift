import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private init() {}
    private let key: String = "OAuth2Token"
}

// MARK: - Interface
extension OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    var token: String? {
        get { KeychainWrapper.standard.string(forKey: key) }
        set { KeychainWrapper.standard.set(newValue!, forKey: key) }
    }
}
