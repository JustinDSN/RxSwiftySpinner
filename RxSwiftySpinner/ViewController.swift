import UIKit
import RxSwift
import RxSwiftExt
import RxCocoa
import NSObject_Rx
import RxSwiftUtilities
import SVProgressHUD

class ViewController: UIViewController {

  @IBOutlet weak var actionButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    let activityIndicator = ActivityIndicator()

    actionButton
      .rx
      .tap
      .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
      .do(onNext: { () in
        SVProgressHUD.show()
      })
      .flatMap({ () -> Observable<String> in
        return GitHubService.getTopRepositories()
          .trackActivity(activityIndicator)
          .flatMap({ Observable.from($0) })
      })
      .flatMap { repositoryName -> Observable<[Event]> in
        return GitHubService.getEvents(repositoryName: repositoryName)
          .trackActivity(activityIndicator)
      }
      .showErrorOrDismiss()
      .catchErrorJustReturn([])
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

//    activityIndicator.asDriver()
//      .drive(SVProgressHUD.rx.isVisible)
//      .disposed(by: rx.disposeBag)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
