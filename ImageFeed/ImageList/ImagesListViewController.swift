import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}
// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfImages
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        guard let imagesListCell = cell as? ImagesListCell
        else {
            return cell
        }
        
        configCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = self.imageForIndexPath(indexPath)
        else { return 0 }
        
        return tableView.bounds.width * image.size.height / image.size.width
    }
}

private extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // ширина градиента больше чем ширина фото, но он обрезается
        cell.gradient.frame.size.width = tableView.bounds.width
        cell.photo.image = self.imageForIndexPath(indexPath)
        cell.label.text = dateFormatter.string(from: Date())
        cell.likeButton.setImage(
            indexPath.row % 2 == 0
            ? UIImage(named: "Active")
            : UIImage(named: "No Active"),
            for: .normal
        )
    }
    func imageForIndexPath(_ indexPath: IndexPath) -> UIImage? {
        UIImage(named: "\(indexPath.row).jpg")
    }
}

private enum Constants {
    static let numberOfImages = 20
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
