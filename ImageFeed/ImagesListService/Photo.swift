import Foundation

struct Photo {
    var id: String
    var size: CGSize
    var createdAt: Date?
    var welcomeDescription: String?
    var thumbImageURL: URL
    var largeImageURL: URL
    var isLiked: Bool
}
