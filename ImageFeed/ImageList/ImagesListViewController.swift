//import Kingfisher
import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private var imagesListService = ImagesListService()

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        addObserver()
        imagesListService.fetchPhotosNextPage()
    }

    deinit {
        removeObserver()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier
        else {
            super.prepare(for: segue, sender: sender)
            return
        }

        guard let viewController = segue.destination as? SingleImageViewController
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        viewController.image = sender as? UIImage
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        imagesListService.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked
        ) { [weak self] result in
            switch result {
            case .success:
                self?.toggleIsLiked(for: photo.id)
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
        return photos.count
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
        let photo = photos[indexPath.row]
        return tableView.bounds.width * photo.size.height / photo.size.width
    }
    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        performSegue(
    //            withIdentifier: showSingleImageSegueIdentifier,
    //            sender: imageForIndexPath(indexPath)
    //        )
    //    }
}

// MARK: - Implementation
extension ImagesListViewController {
    fileprivate func toggleIsLiked(for photoId: String) {
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            photos[keyPath: \.[index].isLiked].toggle()
        }
    }
    fileprivate func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.gradient.frame.size.width = tableView.bounds.width
        let photo = photos[indexPath.row]
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
    @objc fileprivate func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in
            }
        }
    }
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
}

private var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()
