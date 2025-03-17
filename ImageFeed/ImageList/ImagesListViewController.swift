import UIKit

protocol ImageListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}

final class ImagesListViewController: UIViewController {
    var presenter: ImageListViewPresenterProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier
        else {
            super.prepare(for: segue, sender: sender)
            return
        }

        guard let viewController = segue.destination as? SingleImageViewController
        else {
            Logger.shared.error("Invalid segue destination")
            return
        }
        guard let photo = sender as? Photo else {
            Logger.shared.error("нет фото")
            return
        }
        viewController.photo = photo
    }
}

// MARK: - ImageImagesListViewControllerProtocol
extension ImagesListViewController: ImageListViewControllerProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard
            let indexPath = tableView.indexPath(for: cell),
            let photo = presenter?.photos[indexPath.row]
        else {
            return
        }
        UIBlockingProgressHUD.show()
        presenter?.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked
        ) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                cell.setIsLiked(value: !photo.isLiked)
            case .failure(let error):
                Logger.shared.error("Не удалось поменять Like: \(error)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
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
        guard let photo = presenter?.photos[indexPath.row]
        else { return 0 }
        return tableView.bounds.width * photo.size.height / photo.size.width
    }
    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        guard let presenter
        else { return }
        if indexPath.row == presenter.photos.count - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter
        else { return }
        performSegue(
            withIdentifier: showSingleImageSegueIdentifier,
            sender: presenter.photos[indexPath.row]
        )
    }
}

// MARK: - Implementation
extension ImagesListViewController {
    fileprivate func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let presenter
        else { return }
        cell.gradient.frame.size.width = tableView.bounds.width
        let photo = presenter.photos[indexPath.row]
        cell.photo.kf.setImage(
            with: photo.thumbImageURL,
            placeholder: UIImage(named: "Stub")
        )
        cell.photo.kf.indicatorType = .activity
        cell.photo.backgroundColor = UIColor(named: "YP Black")
        if let date = photo.createdAt {
            cell.label.text = dateFormatter.string(from: date)
        } else {
            cell.label.text = nil
        }
        cell.setIsLiked(value: photo.isLiked)
        cell.delegate = self
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()
