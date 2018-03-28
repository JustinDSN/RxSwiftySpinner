import RxSwift
import SVProgressHUD

extension Observable {
  func showErrorHUD() -> Observable<Element> {
    return self.do(onError: { (e) in
      SVProgressHUD.showError(withStatus: "Error \(e.localizedDescription)")
    })
  }

  func showErrorOrDismiss() -> Observable<Element> {
    return self.do(onNext: { (_) in
      SVProgressHUD.dismiss()
    }, onError: { (e) in
      SVProgressHUD.showError(withStatus: "Error \(e.localizedDescription)")
    })
  }
}
