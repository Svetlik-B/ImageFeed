import Foundation

class OAuth2Service {
    static var shared = OAuth2Service()
    private init() {}
    private var task: URLSessionTask?
    private var lastCode: String?
}

struct OAuthTokenResponseBody: Codable {
    var accessToken: String
    var createdAt: Int?
    var refreshToken: String?
    var scope: String?
    var tokenType: String?
    var userId: Int?
    var username: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case createdAt = "created_at"
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
        case userId = "user_id"
        case username
    }
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
        case invalidRequest
    }
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(OAuthError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let urlRequest = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(OAuthError.invalidCode))
            return
        }
        task = URLSession.shared.data(for: urlRequest) { [weak self] result in
            assert(Thread.isMainThread)
            self?.task = nil
            self?.lastCode = nil

            switch result {
            case .success(let data):
                do {
                    let tokenResponseBody = try JSONDecoder().decode(
                        OAuthTokenResponseBody.self, from: data)
                    completion(.success(tokenResponseBody.accessToken))
                } catch {
                    completion(.failure(OAuthError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task?.resume()
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
        else {
            Logger.error("плохой URL для авторизации")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
