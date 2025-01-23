import Foundation

final class OAuth2TokenStorage {
    let key: String = "OAuth2Token"
    var token: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
