// ©2019-2020 Actonica LLC - All Rights Reserved

import Flutter
import UIKit

/*
 Если удалил все отпечатки, то авторизация по пин коду
 Если удалил пин код, то возвращает nil
 */
public class SwiftBiometricsVaultPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.actonica.biometrics_vault", binaryMessenger: registrar.messenger())
    let instance = SwiftBiometricsVaultPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(nil)
      return
    }
    
    switch call.method {
    case "getSecretWithBiometrics":
      do {
        let instructions: String = args["instructions"] as! String
        let key: String = args["key"] as! String
        let accessGroupId: String = args["accessGroupId"] as! String
        let biometricsVault: BiometricsVault = BiometricsVault(accessGroupId: accessGroupId)
        let clear = try biometricsVault.getSecret(key: key, instructions: instructions)
        result(clear)
      } catch {
        result(nil)
      }
    case "setSecretWithBiometrics":
      do {
        let instructions: String = args["instructions"] as! String
        let key: String = args["key"] as! String
        let clear: String = args["clear"] as! String
        let accessGroupId: String = args["accessGroupId"] as! String
        let biometricAuth = BiometricsAuth(instructions:"Unlock with biometrics", completionHandler: AuthCompletionHandler(key: key, clear: clear, accessGroupId: accessGroupId, result: result))
        biometricAuth.auth()
      } catch {
        result(error.localizedDescription)
      }
    case "deleteSecretWithBiometrics":
          do {
            let instructions: String = args["instructions"] as! String
            let key: String = args["key"] as! String
            let accessGroupId: String = args["accessGroupId"] as! String
            let biometricsVault: BiometricsVault = BiometricsVault(accessGroupId: accessGroupId)
            try biometricsVault.deleteSecret(key: key)
            result("Success")
          } catch {
            result(error.localizedDescription)
          }
    default:
      result(nil)
    }
  }
}

class AuthCompletionHandler : CompletionHandler {
  private let key: String
  private let clear: String
  private let accessGroupId: String
  private let result: FlutterResult
  
  init(key: String, clear: String, accessGroupId: String, result: @escaping FlutterResult) {
    self.key = key
    self.clear = clear
    self.accessGroupId = accessGroupId
    self.result = result
  }
  
  func onSuccess() {
    do {
      let biometricsVault: BiometricsVault = BiometricsVault(accessGroupId: self.accessGroupId)
      try biometricsVault.setSecret(key: key, clear: clear)
      result("Success")
    } catch {
      result(error.localizedDescription)
    }
  }
  
  func onFailure() {
    result("Unknown error")
  }
  
  func onError(message: String?) {
    result(message)
  }
}
