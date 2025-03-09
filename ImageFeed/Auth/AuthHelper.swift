import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from urlString: String?) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }

        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString)
        else {
            Logger.shared.error("невозможно создать URLComponents")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope),
        ]

        return urlComponents.url
    }
    func code(from urlString: String?) -> String? {
        guard let urlString,
            let urlComponents = URLComponents(string: urlString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        return codeItem.value
    }
}
