//
//  UIViewController+.swift
//  Money.iOS
//
//  Created by Sergey Petrachkov on 9/15/17.
//  Copyright © 2017 Sergey Petrachkov. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIViewController {
  
  func showErrorAlert(title: String? = nil, message: String) {
    let resolvedTitle = title ?? "Error"
    let alertController = UIAlertController(title: resolvedTitle, message: message, preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    
    self.present(alertController, animated: true, completion: nil)
  }

  func showAwaitingView() {
    MBProgressHUD.showAdded(to: self.view, animated: true)
  }

  func hideAwaitingView() {
    MBProgressHUD.hide(for: self.view, animated: true)
  }

  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
            action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
