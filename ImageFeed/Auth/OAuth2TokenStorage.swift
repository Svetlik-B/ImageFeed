import Foundation

class OAuth2TokenStorage {
    var token: String {
        get { UserDefaults.standard.string(forKey: "OAuth2Token") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "OAuth2Token") }
    }
}
