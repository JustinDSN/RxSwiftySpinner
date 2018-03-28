import Foundation
import RxSwift
import RxSwiftExt

class GitHubService {
  class func getTopRepositories() -> Observable<[String]> {
    return Observable
      .just("https://api.github.com/search/repositories?q=language:swift&per_page=5")
      .map({ (urlString) -> URL? in
        return URL(string: urlString)
      })
      .unwrap()
      .map { url -> URLRequest in
        return URLRequest(url: url)
      }
      .flatMap { request -> Observable<Any> in
        return URLSession.shared.rx.json(request: request)
      }
      .map({ (response) -> [String] in
        guard let response = response as? [String: Any],
          let items = response["items"] as? [[String: Any]] else {
            return []
        }
        return items.map({ $0["full_name"] as! String })
      })
  }

  class func getEvents(repositoryName: String) -> Observable<[Event]> {
    return Observable.just(repositoryName)
      .map({ (urlString) -> URL? in
        return URL(string: "https://api.github.com/repos/\(urlString)/events")
      })
      .unwrap()
      .map { url -> URLRequest in
        return URLRequest(url: url)
      }
      .flatMapFirst { request -> Observable<(response: HTTPURLResponse, data: Data)> in
        return URLSession.shared.rx.response(request: request)
      }
      .filter { response, _ in
        return 200..<300 ~= response.statusCode
      }
      .map { _, data -> [[String: Any]] in
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
          let result = jsonObject as? [[String: Any]] else {
            return []
        }
        return result
      }
      .filter { objects in
        return objects.count > 0
      }
      .map { objects in
        return objects.flatMap(Event.init)
    }
  }
}
