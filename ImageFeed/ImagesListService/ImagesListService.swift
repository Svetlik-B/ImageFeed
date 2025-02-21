import Foundation

final class ImagesListService {
    var photos: [Photo] = []
    var task: URLSessionTask?
}

// MARK: - Interface
extension ImagesListService {
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    func fetchPhotosNextPage() {
        guard task == nil
        else {
            Logger.shared.error("fetchPhotosNextPage еще работает")
            return
        }
        guard let request = urlRequest
        else {
            Logger.shared.error("Ошибка создания URLRequest")
            return
        }
        task = URLSession.shared
            .data(for: request) { [weak self] result in
                defer { self?.task = nil }
                switch result {
                case .success(let data):
                    self?.updatePhotos(data)
                case .failure(let error):
                    Logger.shared.error("\(error)")
                }
            }
        task?.resume()
    }
}

// MARK: - Implementation
extension ImagesListService {
    fileprivate enum Constant {
        static let perPage: Int = 10
    }

    fileprivate enum Error: Swift.Error {
        case invalidURL
    }

    fileprivate var urlRequest: URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(
                name: "page",
                value: "\(photos.count / Constant.perPage + 1)"
            ),
            URLQueryItem(
                name: "per_page",
                value: "\(Constant.perPage)"
            ),
        ]
        guard let url = urlComponents.url else {
            Logger.shared.error("Ошибка создания URL")
            return nil
        }
        guard let token = OAuth2TokenStorage.shared.token else {
            Logger.shared.error("No token")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }

    fileprivate func updatePhotos(_ data: Data) {
        do {
            let responses = try JSONDecoder().decode(
                [Response].self,
                from: data
            )
            let photos = try responses.map { try $0.photo }
            assert(Thread.isMainThread)
            self.photos.append(contentsOf: photos)
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: nil
            )
        } catch {
            Logger.shared.error(error.localizedDescription)
        }
    }

    fileprivate struct Response: Decodable {
        var id: String
        // var size: CGSize
        var width: Int
        var height: Int

        var createdAt: String?  // "created_at"
        var welcomeDescription: String?  // "description"

        // var thumbImageURL: String
        // var largeImageURL: String
        var urls: [String: String]?

        var isLiked: Bool  // "liked_by_user"

        enum CodingKeys: String, CodingKey {
            case id
            case width
            case height
            case createdAt = "created_at"
            case welcomeDescription = "description"
            case urls
            case isLiked = "liked_by_user"
        }

        enum Error: Swift.Error {
            case missingThumbImageURL
            case missingLargeImageURL
        }
        var photo: Photo {
            get throws {
                guard let thumbImageURL = urls?["thumb"]
                else {
                    Logger.shared
                        .error(#"Отсутствует картинка размера "thumb""#)
                    throw Error.missingThumbImageURL
                }
                guard let largeImageURL = urls?["regular"]
                else {
                    Logger.shared
                        .error(#"Отсутствует картинка размера "regular""#)
                    throw Error.missingLargeImageURL
                }
                let isoFormatter = ISO8601DateFormatter()
                let date: Date? =
                    switch createdAt {
                    case .none: nil
                    case .some(let string): isoFormatter.date(from: string)
                    }

                return Photo(
                    id: id,
                    size: CGSize(width: width, height: height),
                    createdAt: date,
                    welcomeDescription: welcomeDescription,
                    thumbImageURL: thumbImageURL,
                    largeImageURL: largeImageURL,
                    isLiked: isLiked
                )
            }
        }
    }
}
