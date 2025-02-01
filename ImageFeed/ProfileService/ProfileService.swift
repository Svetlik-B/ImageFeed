import Foundation

final class ProfileService {

}

// MARK: - Interface
extension ProfileService {
    struct Profile {
        var username: String
        var name: String
        var loginName: String { "@\(username)" }
        var bio: String
    }

    enum Error: Swift.Error {
        case invalidURL
    }

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Swift.Error>) -> Void
    ) {
        // TODO: обработать "гонки"
        guard let url = URL(string: "\(Constant.baseURL)/me")
        else {
            completion(.failure(Error.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        let task = URLSession.shared.data(for: request) { result in
            assert(Thread.isMainThread)
            switch result {
            case .success(let data):
                do {
                    let profileResult = try JSONDecoder()
                        .decode(ProfileResult.self, from: data)
                    completion(.success(Profile(from: profileResult)))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - Implementation
extension ProfileService {
    fileprivate struct ProfileResult: Codable {
        var username: String?
        var firstName: String?
        var lastName: String?
        var bio: String?

        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    fileprivate enum Constant {
        static let baseURL = "https://api.unsplash.com"
    }
}

private extension ProfileService.Profile {
    init (from result: ProfileService.ProfileResult) {
        self.init(
            username: result.username ?? "",
            name: "\(result.firstName ?? "") \(result.lastName ?? "")"
                .trimmingCharacters(in: .whitespaces),
            bio: result.bio ?? ""
        )
    }
}
