//
//  CredentialProviderInteractor.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Alamofire
import Foundation

struct LoginRequest{
  let passphrase: String
}

struct LoginResponse{}

struct SetResourceRequest {
  let user: String
  let resourceId: String
}

protocol LoginInteractorInput {
  func login(request: LoginRequest)
  func setResource(request: SetResourceRequest)
  func tryLoginWithBiometrics()
}

protocol LoginInteractorOutput {
  func didLogin()
  func didReceive(user: String, secret: String)
  func didFail(with error: String)
  func didCancelLoginWithBiometrics()
}

class LoginInteractor: LoginInteractorInput {
  private let interactorOutput: LoginInteractorOutput
  private var cookiesProvider: CookiesProviderInput
  private var selectedResourceProvider: SelectedResourceProviderInput
  private var secretProvider: SecretProviderInput
  private var passphraseProvider: PassphraseProviderInput
  
  init(interactorOutput: LoginInteractorOutput,
       cookiesProvider: CookiesProviderInput,
       selectedResourceProvider: SelectedResourceProviderInput,
       secretProvider: SecretProviderInput,
       passphraseProvider: PassphraseProviderInput
  ) {
    self.interactorOutput = interactorOutput
    self.cookiesProvider = cookiesProvider
    self.selectedResourceProvider = selectedResourceProvider
    self.secretProvider = secretProvider
    self.passphraseProvider = passphraseProvider
  }
  
  func login(request: LoginRequest) {
    print("login in interactor, request \(request.passphrase)")
    sendFingerprint(passphrase: request.passphrase)
  }
  
  func setResource(request: SetResourceRequest) {
    self.selectedResourceProvider.user = request.user
    self.selectedResourceProvider.resourceId = request.resourceId
  }
  
  func tryLoginWithBiometrics() {
    if SharedKeychain.aliasPassphraseKey() != nil {
      if let passphrase = SharedKeychain.passphrase() {
        self.sendFingerprint(passphrase: passphrase)
      } else {
        self.interactorOutput.didFail(with: "Check your biometrics")
      }
    } else {
      self.interactorOutput.didCancelLoginWithBiometrics()
    }
  }
  
  private func sendFingerprint(passphrase: String) {
    if let fingerprint = SharedKeychain.fingerprint(), let baseUrl = SharedKeychain.baseUrl(), var privateKey = SharedKeychain.privateKey() {
      let parameters: [String: String] = [
        "data[gpg_auth][keyid]":fingerprint
      ]
      
      AF.request("\(baseUrl)/auth/login.json?api-version=v2", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody)).response { response in
        if let error = response.error {
          print(error.localizedDescription)
          self.interactorOutput.didFail(with: "Check your internet connection.")
        } else {
          if var encryptedNonce = response.response?.allHeaderFields["X-GPGAuth-User-Auth-Token"] as? String {
            do {
              self.sendDecryptedNonce(data: try Cipher.decrypt(cipherText: encryptedNonce, key: privateKey, passphrase: passphrase), passphrase: passphrase)
            } catch {
              self.interactorOutput.didFail(with: "Check your private key and passphrase.")
            }
          } else {
            self.interactorOutput.didFail(with: "Server error.")
          }
        }
      }
    } else {
      self.interactorOutput.didFail(with: "You need setup your Passbolt server in the application")
    }
  }
  
  private func sendDecryptedNonce(data: String, passphrase: String) {
    if let fingerprint = SharedKeychain.fingerprint(), let baseUrl = SharedKeychain.baseUrl(){
      let parameters: [String: String] = [
        "data[gpg_auth][keyid]": fingerprint,
        "data[gpg_auth][user_token_result]": data
      ]
      
      AF.request("\(baseUrl)/auth/login.json?api-version=v2", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody)).response { response in
        if let error = response.error {
          print(error.localizedDescription)
          self.interactorOutput.didFail(with: "Check your internet connection.")
        } else {
          if let cookies = response.response?.allHeaderFields["Set-Cookie"] as? String {
            self.cookiesProvider.cakePHP = String(cookies.split(separator: ";")[0])
            self.passphraseProvider.passhphrase = passphrase
            
            if let resourceId =  self.selectedResourceProvider.resourceId, let user = self.selectedResourceProvider.user {
              print("resourceId: \(resourceId)")
              self.secretProvider.getSecret(resourceId: resourceId, passphrase: passphrase, success: {(secret: String) in
                self.selectedResourceProvider.resourceId = nil
                self.interactorOutput.didReceive(user: user, secret: secret)
              }, failure: {(error: String) in
                self.interactorOutput.didFail(with: error)
              })
            } else {
              self.interactorOutput.didLogin()
            }
          }
        }
      }
    } else {
      self.interactorOutput.didFail(with: "You need setup your Passbolt server in the application")
    }
  }
}
