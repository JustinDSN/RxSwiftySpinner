import UIKit
import RxSwift
import RxSwiftExt
import RxCocoa
import NSObject_Rx
import RxSwiftUtilities
import SVProgressHUD

class ViewController: UIViewController {

  @IBOutlet weak var actionButton: UIButton!

  private func getTopRepositories() -> Observable<[String]> {
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

  private func getEvents(repositoryName: String) -> Observable<[Event]> {
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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    let activityIndicator = ActivityIndicator()

    actionButton
      .rx
      .tap
      .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
//      .map({ return "ReactiveX/RxSwift" })
      .flatMap({ () -> Observable<String> in
        return self.getTopRepositories()
          .trackActivity(activityIndicator)
          .flatMap({ Observable.from($0) })
      })
      .flatMap { repositoryName -> Observable<[Event]> in
        //TODO: Do we need to capture self weakly here?
        return self.getEvents(repositoryName: repositoryName)
          .trackActivity(activityIndicator)
      }
      .subscribe(onNext: { (value) in
        print(value)
      }, onError: { (error) in
        print("Error ⚠️: \(error)")
      }, onCompleted: {
        print("Completed")
      }, onDisposed: {
        print("Disposed");
      })
      .disposed(by: rx.disposeBag)


    activityIndicator.asDriver()
      .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
      .disposed(by: rx.disposeBag)

    activityIndicator.asDriver()
      .drive(SVProgressHUD.rx.isVisible)
      .disposed(by: rx.disposeBag)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
