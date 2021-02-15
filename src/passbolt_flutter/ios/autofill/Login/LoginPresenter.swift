//
//  CredentialProviderPresenter.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

protocol LoginPresenterInput {
  func login(userInput: String?)
  func setResource(user: String, resourceId: String?)
  func tryLoginWithBiometrics()
}

protocol LoginPresenterOutput {
  func didChangeState(state: LoginState)
}

class LoginPresenter: LoginPresenterInput, LoginInteractorOutput {
  var presenterOutput: LoginPresenterOutput?
  var interactorInput: LoginInteractorInput?
  
  init(presenterOutput: LoginPresenterOutput) {
    self.presenterOutput = presenterOutput
  }
  
  func login(userInput: String?) {
    self.presenterOutput?.didChangeState(state: .pending)
    if let input = userInput, !input.isEmpty {
      self.interactorInput?.login(request: LoginRequest(passphrase: input))
    } else {
      self.presenterOutput?.didChangeState(state: LoginState.error("Error"))
    }
  }
  
  func setResource(user: String, resourceId: String?) {
    print("presenter setRecordIdentifier user: \(user) resourceId: \(resourceId)")
    if let resourceId = resourceId {
      self.interactorInput?.setResource(request: SetResourceRequest(user: user, resourceId: resourceId))
    }
  }
  
  func tryLoginWithBiometrics() {
    self.presenterOutput?.didChangeState(state: .pending)
    self.interactorInput?.tryLoginWithBiometrics()
  }
  
  func didCancelLoginWithBiometrics() {
    self.presenterOutput?.didChangeState(state: .cancelLoginWithBiometrics)
  }
  
  func didLogin() {
    print("login complete")
    self.presenterOutput?.didChangeState(state: LoginState.login)
  }
  
  func didReceive(user: String, secret: String) {
    self.presenterOutput?.didChangeState(state: LoginState.secret(user, secret))
  }
  
  func didFail(with error: String) {
    self.presenterOutput?.didChangeState(state: LoginState.error(error))
  }
}

enum LoginState {
  case error(String), secret(String, String), login, pending, cancelLoginWithBiometrics
}
