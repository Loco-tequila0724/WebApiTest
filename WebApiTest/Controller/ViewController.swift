import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let webAPIModel = WebAPIModel()
    private var news = News(articles: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        Task {
            await configure()
        }
    }
}

private extension ViewController {
    //   async/await ver.
    func configure() async {
        do {
            let result = try await webAPIModel.fetchNewsAsyncAwait()
            switch result {
            case .success(let news):
                self.news = news
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        } catch let error {
            print(error)
        }
    }
    //   completionHandler ver.
    func configure() {
        webAPIModel.fetchNews { result in
            switch result {
            case .success(let news):
                self.news = news
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier) as? NewsTableViewCell else { return UITableViewCell() }
        let imageURL: URL = URL(string: news.articles[indexPath.row].urlToImage)!
        let title = news.articles[indexPath.row].title
        let description = news.articles[indexPath.row].description

        cell.configure(
            title: title,
            description: description
        )
        cell.newsImageView().loadImageAsynchronous(url: imageURL)

        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

private extension UIImageView {
    func loadImageAsynchronous(url: URL?) {
        guard let url else { return }
        Task.detached {
            let imageData: Data? = try Data(contentsOf: url)
            guard let imageData else { return }
            await MainActor.run {
                self.image = UIImage(data: imageData)
            }
        }
    }
}
