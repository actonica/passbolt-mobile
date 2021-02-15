//
//  SharedKeychain.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

class SharedKeychain {
  
  private static var accessGroupId = "B5GS5KEWV8.com.actonica.pb.shareditems"
  
  static func baseUrl() -> String? {
    return read(key: "SecureStorageKey.BASE_URL")
  }
  
  static func privateKey() -> String? {
    return read(key: "SecureStorageKey.PRIVATE_KEY_ASC")
  }
  
  static func fingerprint() -> String? {
    return read(key: "SecureStorageKey.PUBLIC_KEY_FINGERPRINT")
  }
  
  static func aliasPassphraseKey() -> String? {
    return read(key: "SecureStorageKey.ALIAS_FOR_PASSPHRASE_KEY")
  }
  
  static func passphrase() -> String? {
    if let alias = read(key: "SecureStorageKey.ALIAS_FOR_PASSPHRASE_KEY"){
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: alias,
        kSecAttrAccessGroup as String: accessGroupId,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: false,
        kSecUseOperationPrompt as String: "Login with biometry",
        kSecReturnData as String: true]
      
      var dataTypeRef: AnyObject? = nil
      
      let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
      
      if status == noErr {
        return String(data: (dataTypeRef as! Data), encoding: String.Encoding.utf32)
      } else {
        return nil
      }
    }
    
    return nil
  }
  
  private static func read(key: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecAttrAccessGroup as String: accessGroupId,
      kSecReturnData as String: true]
    
    var dataTypeRef: AnyObject? = nil
    
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == noErr {
      return String(data: (dataTypeRef as! Data), encoding: String.Encoding.utf8)
    } else {
      print(status.description)
      return nil
    }
  }
}
