import Foundation

final class ProfileImageService {
    private(set) var imageURL: URL? {
        didSet {
            if oldValue != imageURL {
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": imageURL as Any]
                )
            }
        }
    }
    private var task: URLSessionTask?
    private(set) var lastUsername: String?
    private init() {}
}

// MARK: - Interface
extension ProfileImageService {
    static let didChangeNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange"
    )
    static let shared = ProfileImageService()
    enum Error: Swift.Error {
        case invalidURL
        case invalidRequest
        case noToken
    }
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<URL, Swift.Error>) -> Void
    ) {
        guard lastUsername != username else {
            completion(.failure(Error.invalidRequest))
            return
        }
        task?.cancel()
        lastUsername = username

        guard let url = URL(string: "\(Constant.baseURL)/users/\(username)")
        else {
            completion(.failure(Error.invalidURL))
            return
        }
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(Error.noToken))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
            self.task = nil
            self.lastUsername = nil

            switch result {
            case .success(let data):
                do {
                    let imageResult = try JSONDecoder()
                        .decode(ProfileImageResult.self, from: data)
                    let url = imageResult.profileImage.small
                    self.imageURL = url
                    completion(.success(url))
                } catch {
                    completion(.failure(error))
                    return
                }

            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        task?.resume()
    }
}

// MARK: - Implementation
extension ProfileImageService {
    fileprivate enum Constant {
        static let baseURL = "https://api.unsplash.com"
    }
    fileprivate struct ProfileImageResult: Codable {
        var profileImage: ProfileImageStruct
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
        struct ProfileImageStruct: Codable {
            var small: URL
        }
    }
}
