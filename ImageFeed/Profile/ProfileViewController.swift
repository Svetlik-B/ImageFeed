import Combine
import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let textLabel = UILabel()
    private let imageView = UIImageView()
    private var cancellable: Cancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        cancellable = ProfileImageService.shared
            .publisher(for: \.imageURL).sink { imageURL in
                guard let imageURL = imageURL else { return }
                DispatchQueue.main.async {
                    let processor = RoundCornerImageProcessor(cornerRadius: 20)
                    self.imageView.kf.setImage(
                        with: imageURL,
                        placeholder: UIImage(named: "tab_profile_active"),
                        options: [.processor(processor), .forceRefresh]
                    )
                }
            }
        setupUI()
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
    }

    @objc
    private func buttonLogin() {}
}

// MARK: - Implementation
extension ProfileViewController {
    fileprivate enum Constant {
        static let imageDiameter: CGFloat = 70
    }
    fileprivate func updateProfileDetails(profile: ProfileService.Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        textLabel.text = profile.bio
    }
    fileprivate func setupUI() {
        view.backgroundColor = UIColor(named: "YP Black")
        imageView.tintColor = .gray
        let buttonEntrance = UIButton.systemButton(
            with: UIImage(named: "Exit") ?? UIImage(),
            target: self,
            action: #selector(buttonLogin))

        [imageView, nameLabel, loginLabel, textLabel, buttonEntrance].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constant.imageDiameter),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        ])

        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
        ])

        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = UIColor.ypGray
        NSLayoutConstraint.activate([
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        ])

        textLabel.text = "Hello, World!"
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.textColor = .white
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
        ])

        buttonEntrance.tintColor = UIColor.ypRed
        NSLayoutConstraint.activate([
            buttonEntrance.widthAnchor.constraint(equalToConstant: 44),
            buttonEntrance.heightAnchor.constraint(equalToConstant: 44),
            buttonEntrance.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide
                    .trailingAnchor, constant: -16),
            buttonEntrance.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }

}
