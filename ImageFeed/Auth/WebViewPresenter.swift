import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from urlString: String?) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: (any WebViewViewControllerProtocol)?
    var authHelper: AuthHelperProtocol
       
       init(authHelper: AuthHelperProtocol) {
           self.authHelper = authHelper
       }

    func viewDidLoad() {
        didUpdateProgressValue(0)
        guard let request = authHelper.authRequest()
        else {
            Logger.shared.error("плохой authRequest")
            return
        }
        view?.load(request: request)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func code(from urlString: String?) -> String? {
        return authHelper.code(from: urlString)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
