//
//  ResourcesListInteractor.swift
//  autofill
//
//  Created by Роман Митюков on 21.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol ResourcesListInteractorInput {
  func getResources()
  func getSecret(resource: Resource)
}

protocol ResourcesListInteractorOutput {
  func didReceive(resources: [Resource])
  func didReceive(username: String, secret: String)
  func didFail(with error: String)
}

class ResourcesListInteractor: ResourcesListInteractorInput {
  private let interactorOutput: ResourcesListInteractorOutput
  private var cookiesProvider: CookiesProviderInput
  private var selectedResourceProvider: SelectedResourceProviderInput
  private var secretProvider: SecretProviderInput
  private var passphraseProvider: PassphraseProviderInput
  
  init(interactorOutput: ResourcesListInteractorOutput,
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
  
  func getResources() {
    if let baseUrl = SharedKeychain.baseUrl(), let cakePHP = self.cookiesProvider.cakePHP {
      let headers = HTTPHeaders(["Cookie" : cakePHP])
      AF.request("\(baseUrl)/resources.json?api-version=v2", method: .get, parameters: nil, headers: headers).responseJSON {response in
        if let error = response.error {
          self.interactorOutput.didFail(with: error.localizedDescription)
        } else {
          if let data = response.data {
            do {
              let jsonObject = try JSON(data: data)
              let resourceJsonList = jsonObject["body"]
              let resourceList: [Resource] = resourceJsonList.compactMap{ json in
                if let name = json.1["name"].string,
                  let resourceId = json.1["id"].string {
                  return Resource(name: name,
                                  username: json.1["username"].string ?? "n/a",
                                  uri: json.1["uri"].string ?? "n/a",
                                  description: json.1["description"].string ?? "n/a",
                                  resourceId: resourceId
                  )
                } else {
                  return nil
                }
              }
              
              self.interactorOutput.didReceive(resources: resourceList)
            } catch {
              self.interactorOutput.didFail(with: error.localizedDescription)
            }
          }
        }
      }
    }
  }
  
  func getSecret(resource: Resource) {
    if let passphrase = self.passphraseProvider.passhphrase {
      self.secretProvider.getSecret(resourceId: resource.resourceId, passphrase: passphrase, success: {secret in
        self.interactorOutput.didReceive(username:resource.username, secret: secret)
      }, failure: {error in
        self.interactorOutput.didFail(with: error)
      })
    } else {
      self.interactorOutput.didFail(with: "Empty passphrase.")
    }
  }
}
