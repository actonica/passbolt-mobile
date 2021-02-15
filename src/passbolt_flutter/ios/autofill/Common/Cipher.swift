//
//  Cipher.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

class Cipher {
  static func decrypt(cipherText: String, key: String, passphrase: String) throws -> String {
    var cipherTextData = cipherText
    var keyData = key
    keyData = keyData.replacingOccurrences(of: "\n \n", with: "\n\n")
    
    
    
    cipherTextData = cipherTextData.removingPercentEncoding!
    cipherTextData = cipherTextData.replacingOccurrences(of: "BEGIN\\+PGP\\+MESSAGE", with: "BEGIN PGP MESSAGE").replacingOccurrences(of: "END\\+PGP\\+MESSAGE", with: "END PGP MESSAGE")
    
let decryptor = Decryptor()
decryptor.setup()
let clearText = decryptor.decrypt(cipherTextData, privateKey: keyData, passphrase: passphrase)
    return clearText!
  }
}
