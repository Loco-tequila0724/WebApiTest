import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet private weak var newsImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    static let identifier = "NewsCell"

    func configure(title: String, description: String) {
        self.titleLabel.text = title
        self.textView.text = description
    }

    func createImage(newsImage: UIImage) {
        self.newsImage.image = newsImage
    }

    func newsImageView() -> UIImageView {
        return newsImage
    }
}
