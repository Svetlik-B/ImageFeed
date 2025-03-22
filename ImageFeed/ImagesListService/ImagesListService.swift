import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ImagesListService: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var task: URLSessionTask?
}

// MARK: - Interface
extension ImagesListService {
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    enum ImagesListServiceError: Error {
        case badChangeLikeUrl
        case noToken
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print(#function, photoId, isLike)
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString)
        else {
            Logger.shared.error("changeLike: Ошибка создания URL")
            completion(.failure(ImagesListServiceError.badChangeLikeUrl))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        guard let token = OAuth2TokenStorage.shared.token
        else {
            Logger.shared.error("changeLike: Отсутствует токен")
            completion(.failure(ImagesListServiceError.noToken))
            return
        }
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        URLSession.shared.data(for: request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()

    }
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
                [PhotoResponse].self,
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

    fileprivate struct PhotoResponse: Decodable {
        var id: String
        var width: Int
        var height: Int

        var createdAt: String?
        var welcomeDescription: String?

        var urls: [String: String]?

        var isLiked: Bool
        enum CodingKeys: String, CodingKey {
            case id
            case width
            case height
            case createdAt = "created_at"
            case welcomeDescription = "description"
            case urls
            case isLiked = "liked_by_user"
        }

        enum ResponseError: Error {
            case missingThumbImageURL
            case missingLargeImageURL
        }
        var photo: Photo {
            get throws {
                guard
                    let thumbImage = urls?["thumb"],
                    let thumbImageURL = URL(string: thumbImage)
                else {
                    Logger.shared
                        .error(#"Отсутствует картинка размера "thumb""#)
                    throw ResponseError.missingThumbImageURL
                }
                guard
                    let fullImage = urls?["full"],
                    let fullImageURL = URL(string: fullImage)
                else {
                    Logger.shared
                        .error(#"Отсутствует картинка размера "full""#)
                    throw ResponseError.missingLargeImageURL
                }
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
                    largeImageURL: fullImageURL,
                    isLiked: isLiked
                )
            }
        }
    }
}

private let isoFormatter = ISO8601DateFormatter()
