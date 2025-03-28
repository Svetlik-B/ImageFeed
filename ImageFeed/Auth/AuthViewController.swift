import Foundation
import UIKit

private let showWebViewSegueIdentifier = "ShowWebView"

protocol AuthViewControllerDelegate: NSObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    var delegate: AuthViewControllerDelegate?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                Logger.shared.error("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewViewController.delegate = self
            webViewPresenter.view = webViewViewController
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        navigationController?.popViewController(animated: true)
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                Logger.shared.error(error.localizedDescription)
                let allert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )
                allert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(allert, animated: true)
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
