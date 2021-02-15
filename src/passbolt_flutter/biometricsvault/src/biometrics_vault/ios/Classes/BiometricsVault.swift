// ©2019-2020 Actonica LLC - All Rights Reserved

import Foundation
import LocalAuthentication
import Security

class BiometricsVaultError: Error {
  let code: Int
  
  init(code: Int) {
    self.code = code
  }
}

class BiometricsVault {
  private let accessGroupId: String
  
  init(accessGroupId: String) {
    self.accessGroupId = accessGroupId
  }
  
  func setSecret(key: String, clear: String) throws {
    let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
    let context = LAContext()
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccessControl as String: access as Any,
      kSecAttrAccount as String: key,
      kSecAttrAccessGroup as String: accessGroupId,
      kSecUseAuthenticationContext as String: context,
      kSecValueData as String: clear.data(using: String.Encoding.utf32)]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    
    if status != noErr {
      throw BiometricsVaultError(code: Int(status))
    }
  }
  
  func getSecret(key: String, instructions: String) throws -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecAttrAccessGroup as String: accessGroupId,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnAttributes as String: false,
      kSecUseOperationPrompt as String: instructions,
      kSecReturnData as String: true]
    
    var dataTypeRef: AnyObject? = nil
    
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == noErr {
      return String(data: (dataTypeRef as! Data), encoding: String.Encoding.utf32)
    } else {
      return nil
    }
  }
  
  func deleteSecret(key: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecAttrAccessGroup as String: accessGroupId,]
    
    let status = SecItemDelete(query as CFDictionary)
    
    if status != noErr {
      throw BiometricsVaultError(code: Int(status))
    }
  }
}
