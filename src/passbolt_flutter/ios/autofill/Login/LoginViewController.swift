//
//  CredentialProviderViewController.swift
//  autofill
//
//  Created by roman.mityukov@actonica.ru on 14.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import AuthenticationServices

class LoginViewController: UIViewController {
  @IBOutlet weak var userInput: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  
  var presenter: LoginPresenterInput?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.hideKeyboardWhenTappedAround()
    self.loginButton.isEnabled = false
    self.userInput.addTarget(self, action: #selector(inputDidChanged(textField:)), for: .editingChanged)
    
    if presenter == nil {
      self.presenter = LoginDI.providePresenter(presenterOutput: self)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.presenter?.tryLoginWithBiometrics()
  }
  
  @objc func inputDidChanged(textField: UITextField) {
    if let text = textField.text, !text.isEmpty {
      self.loginButton.isEnabled = true
    } else {
      self.loginButton.isEnabled = false
    }
  }
  
  @IBAction func login(_ sender: Any) {
    self.presenter?.login(userInput: self.userInput.text)
  }
  
  @IBAction func cancel(_ sender: AnyObject?) {
    (self.extensionContext as? ASCredentialProviderExtensionContext)?.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
  }
}

extension LoginViewController: LoginPresenterOutput {
  func didChangeState(state: LoginState) {
    self.hideAwaitingView()
    switch state{
    case .error(let message):
      self.showErrorAlert(message: message)
    case .secret(let user, let secret):
      (self.extensionContext as? ASCredentialProviderExtensionContext)?.completeRequest(withSelectedCredential: ASPasswordCredential(user: user, password: secret), completionHandler: nil)
    case .login:
      let storyboard = UIStoryboard(name: "ResourcesList", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "ResourcesListController") as! ResourcesListController
      self.navigationController?.pushViewController(viewController, animated: false)
    case .pending:
      self.showAwaitingView()
    default:
      return
    }
  }
}
