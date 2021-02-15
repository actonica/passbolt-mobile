//
//  SecretProvider.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol SecretProviderInput {
  func getSecret(resourceId: String,
                 passphrase: String,
                 success: @escaping (_: String) -> Void,
                 failure: @escaping (_: String) -> Void
  )
}

class SecretProvider: SecretProviderInput {
  private let cookiesProvider: CookiesProviderInput
  
  init(cookiesProvider: CookiesProviderInput) {
    self.cookiesProvider = cookiesProvider
  }
  
  func getSecret(resourceId: String,
                 passphrase: String,
                 success: @escaping (_: String) -> Void,
                 failure: @escaping (_: String) -> Void
  ) {
    if let baseUrl = SharedKeychain.baseUrl(), let privateKey = SharedKeychain.privateKey(), let cakePHP = self.cookiesProvider.cakePHP {
      let headers = HTTPHeaders(["Cookie" : cakePHP])
      AF.request(
        "\(baseUrl)/secrets/resource/\(resourceId).json?api-version=v2",
        method: .get,
        parameters: nil,
        headers: headers).responseJSON { response in
          if let error = response.error {
            failure(error.localizedDescription)
          } else {
            if let data = response.data {
              do {
                let jsonObject = try JSON(data: data)
                if let secret = jsonObject["body"]["data"].string {
                  let clear = try Cipher.decrypt(cipherText: secret, key: privateKey, passphrase: passphrase)
                  success(clear)
                }
              } catch {
                failure(error.localizedDescription)
              }
            }
          }
      }
    } else {
      failure("Client error. Relaunch autofill, please.")
    }
  }
}
