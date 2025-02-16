import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        func fulfillCompletionOnTheMainThread(_ result: Result<Data, Error>) {
            if case .failure(let failure) = result {
                Logger.shared.error("\(failure)")
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
            else {
                if let error = error {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                }
                return
            }

            guard 200..<300 ~= statusCode
            else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }

            fulfillCompletionOnTheMainThread(.success(data))
        }

        return task
    }
}
