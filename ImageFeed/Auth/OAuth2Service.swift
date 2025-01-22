import Foundation

class OAuth2Service {
    static var shared = OAuth2Service()
    private init() {}
    private var tokenResponseBody: OAuthTokenResponseBody?
}

struct OAuthTokenResponseBody: Codable {
    var access_token: String
    var created_at: Int?
    var refresh_token: String?
    var scope: String?
    var token_type: String?
    var user_id: Int?
    var username: String?
}

extension OAuthTokenResponseBody: CustomStringConvertible {
    var description: String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let json = try encoder.encode(self)
            return String(decoding: json, as: UTF8.self)
        } catch {
            return "Error encoding token: \(error)"
        }
    }
}

// MARK: - Interace

extension OAuth2Service {
    enum OAuthError: Error {
        case invalidCode
        case invalidResponse
    }
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let urlRequest = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(OAuthError.invalidCode))
            return
        }
        let dataTask = URLSession.shared.data(for: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponseBody = try JSONDecoder().decode(
                        OAuthTokenResponseBody.self, from: data)
                    completion(.success(tokenResponseBody.access_token))
                } catch {
                    completion(.failure(OAuthError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}

// MARK: - Implementation

extension OAuth2Service {
    fileprivate func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        guard let url = urlComponents.url
        else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
