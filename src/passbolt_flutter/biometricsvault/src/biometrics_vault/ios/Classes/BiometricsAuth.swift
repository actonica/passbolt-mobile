// ©2019-2020 Actonica LLC - All Rights Reserved

import Foundation
import LocalAuthentication

protocol CompletionHandler {
  func onSuccess()
  func onFailure()
  func onError(message: String?)
}

class BiometricsAuth {
  private let completionHandler: CompletionHandler
  private let instructions: String
  private let context = LAContext()
  
  init(instructions: String, completionHandler: CompletionHandler) {
    self.instructions = instructions
    self.completionHandler = completionHandler
  }
  
  func auth() {
    self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: self.instructions, reply: {(success: Bool, error: Error?) in
      
      DispatchQueue.main.async {
        if let error = error {
          let message: String
                                
          switch error {
          case LAError.authenticationFailed:
            message = "There was a problem verifying your identity."
          case LAError.userCancel:
            message = "You pressed cancel."
          case LAError.userFallback:
            message = "You pressed password."
          case LAError.biometryNotAvailable:
            message = "Face ID/Touch ID is not available."
          case LAError.biometryNotEnrolled:
            message = "Face ID/Touch ID is not set up."
          case LAError.biometryLockout:
            message = "Face ID/Touch ID is locked."
          default:
            message = "Face ID/Touch ID may not be configured"
          }
          
          self.completionHandler.onError(message: message)
          return
        }
        
        if (success) {
          self.completionHandler.onSuccess()
        } else {
          self.completionHandler.onFailure()
        }
      }
      })
  }
  
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
}
