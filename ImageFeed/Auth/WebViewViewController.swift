import Foundation
import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var progressView: UIProgressView!

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "UnsplashWebView"
        configureBackButton()
        progressView.progress = 0
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) ->
            Void
    ) {
        if let code = presenter?.code(from: navigationAction.request.url?.absoluteString)
        {
            decisionHandler(.cancel)
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
        } else {
            decisionHandler(.allow)
        }
    }
}

// MARK: - Implementation
extension WebViewViewController {
    fileprivate func configureBackButton() {
        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )
        backButton.setImage(
            Constant.backward.withTintColor(Constant.black),
            for: .normal
        )
        backButton.setImage(
            Constant.backward.withTintColor(Constant.gray),
            for: .highlighted
        )
    }
}

private enum Constant {
    static var backward: UIImage {
        let imageName = "Backward"
        lazy var warning = "Не определено изображение '\(imageName)'"
        let image = UIImage(named: imageName)
        assert(image != nil, warning)
        guard let image
        else {
            Logger.shared.error(warning)
            return UIImage()
        }
        return image
    }
    static var black: UIColor {
        assert(UIColor(named: "YP Black") != nil, "Не определён цвет 'YP Black'")
        guard let color = UIColor(named: "YP Black")
        else {
            Logger.shared.error("Не определён цвет 'YP Black'")
            return UIColor.black
        }
        return color
    }
    static var gray: UIColor {
        assert(UIColor(named: "YP Gray") != nil, "Не определён цвет 'YP Gray'")
        guard let color = UIColor(named: "YP Gray")
        else {
            Logger.shared.error("Не определён цвет 'YP Gray'")
            return UIColor.gray
        }
        return color
    }
}
