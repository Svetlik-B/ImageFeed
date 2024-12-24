import UIKit

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorInset = .init(top: 50, left: 0, bottom: 0, right: 0)

    }
}
// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
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
        guard
            let image = UIImage(named: "\(indexPath.row).jpg")
        else { return 200 }
        
        return tableView.frame.width * image.size.height / image.size.width
    }
}

private extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        let image: UIImage? = UIImage(named: "\(indexPath.row).jpg")
        
        
        
        cell.label.text = formatter.string(from: Date())
        cell.likeButton.setImage(
            indexPath.row % 2 == 0 ? UIImage(named: "Active") : UIImage(named: "No Active"),
            for: .normal
        )
        cell.photo.image = image
    }
}
