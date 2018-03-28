import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

extension Reactive where Base: SVProgressHUD {
  public static var isVisible: Binder<Bool> {
    return Binder(UIApplication.shared) {progressHUD, isVisible in
      if isVisible {
        SVProgressHUD.show()
      } else {
        SVProgressHUD.dismiss()
      }
    }
  }

//  static var status: Binder<String?> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.show(withStatus: value)
//    }
//  }
//
//  static func status(withImage image: UIImage) -> Binder<String?> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.show(image, status: value)
//    }
//  }
//
//  static var infoStatus: Binder<String?> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.showInfo(withStatus: value)
//    }
//  }
//
//  static var error: Binder<Error> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.showError(withStatus: value.localizedDescription)
//    }
//  }
//
//  static var errorStatus: Binder<String?> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.showError(withStatus: value)
//    }
//  }
//
//  static var successStatus: Binder<String?> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.showSuccess(withStatus: value)
//
//    }
//  }
//
//  static var progress: Binder<Float> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.showProgress(value)
//    }
//  }
//
//  static func progress(withStatus status: String) -> Binder<Float> {
//    return Binder(UIApplication.shared) { (_, value) in
//      SVProgressHUD.showProgress(value, status: status)
//    }
//  }
}
