import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController")
        
        if let vc = imagesListViewController as? ImagesListViewController {
            vc.presenter = ImageListViewPresenter(
                view: vc,
                imagesListService: ImagesListService()
            )
        } else {
            Logger.shared.error("Could not cast imagesListViewController to ImagesListViewController")
        }
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_no_active")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "tab_editorial_active")
        )
        let profileViewController = ProfileViewController()
        profileViewController.presenter = ProfileViewPresenter(view: profileViewController)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_no_active")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "tab_profile_active")
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
