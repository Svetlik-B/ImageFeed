import Foundation
import UIKit
import WebKit

class WebViewViewController: UIViewController {
    let showWebViewSegueIdentifier = "ShowWebView"

    @IBOutlet private var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
}

private extension WebViewViewController {
    func configureBackButton() {
        // TODO: исправить код замены back button
        navigationController?.navigationBar.backIndicatorImage = UIImage(
            named: "Backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage =
            UIImage(named: "Backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}
