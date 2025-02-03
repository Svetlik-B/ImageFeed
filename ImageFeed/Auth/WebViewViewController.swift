import Foundation
import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let path = "/oauth/authorize/native"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    weak var delegate: WebViewViewControllerDelegate?
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var progressView: UIProgressView!

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = 0
        webView.navigationDelegate = self
        configureBackButton()
        loadAuthView()
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
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        progressView.setProgress(
            Float(webView.estimatedProgress),
            animated: true
        )
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
        if let code = code(from: navigationAction) {
            decisionHandler(.cancel)
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
        } else {
            decisionHandler(.allow)
        }
    }
}

// MARK: - Implementation
extension WebViewViewController {
    fileprivate func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == WebViewConstants.path,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    fileprivate func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString)
        else {
            Logger.shared.error("невозможно создать URLComponents")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]
        guard let url = urlComponents.url
        else {
            Logger.shared.error("невозможно создать URL")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

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
