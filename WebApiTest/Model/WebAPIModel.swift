import Foundation

struct News: Codable {
    var articles: [Articles]

    struct Articles: Codable {
        let title: String
        let description: String
        let urlToImage: String
    }
//    enum CodingKeys: CodingKey {
//        case title
//        case description
//        case urlToImage
//    }
}

enum ApiError: Error {
    case networkError // ネットワーク接続に問題があるため、リクエストが失敗した場合に返される。
    case invalidResponse //サーバーから不正なレスポンスが返された場合に返されるエラーコードです。たとえば、予期しない形式のJSONデータが返された場合など。
    case unauthorized // 認証が必要なリクエストを実行する際に、認証されていない状態でリクエストを行った場合に返される。
    case forbidden // リクエストされたアクションを実行するための権限がない場合に返される。
    case notFound // リクエストされたリソースが見つからなかった場合に返される。
    case invalidData // サーバーから受信したデータが正しく解析できない場合に返される。
    case serverError // サーバー側で何らかの問題が発生し、リクエストを処理できない場合に返される。
    case timeout // リクエストがタイムアウトした場合に返されるエラーコードです。サーバー側が遅い場合や、ネットワーク接続が不安定な場合などで発生します。
    case unknown // 上記のいずれにも該当しない、原因不明のエラーが発生した場合に返される。
}

protocol WebAPIProtocol {
    func fetchNews(completion: @escaping(Result<News, Error>) -> Void)
    // 変更すること
    func fetchNewsAsyncAwait() async throws -> (Result<News, Error>)
}

final class WebAPIModel: WebAPIProtocol {
    let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=f4411151fdf54ba18bffab8fda07c016")
    let decoder = JSONDecoder()
}

extension WebAPIModel {
    //   completionHandler ver.
    func fetchNews(completion: @escaping(Result<News, Error>) -> Void) {
        guard let url else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(ApiError.serverError))
                return
            }

            if let data, let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 {
                do {
                    let news = try self.decoder.decode(News.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(news))
                    }
                } catch {
                    completion(.failure(ApiError.networkError))
                }
            } else {
                completion(.failure(ApiError.serverError))
            }
        }
        task.resume()
    }


    //   async/await ver.
    func fetchNewsAsyncAwait() async throws -> (Result<News, Error>) {
        guard let url else { return .failure(ApiError.notFound) }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else { return .failure(ApiError.serverError) }

        let news = try decoder.decode(News.self, from: data)
        return .success(news)

    }
}
