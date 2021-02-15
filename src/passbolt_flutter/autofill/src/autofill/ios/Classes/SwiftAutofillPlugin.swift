import Flutter
import AuthenticationServices
import UIKit

public class SwiftAutofillPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "autofill", binaryMessenger: registrar.messenger())
        let instance = SwiftAutofillPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "addCredentials":
            guard let args = call.arguments as? [String: Any] else {
                result(nil)
                return
            }
            if let credentialsData = args["credentialsData"] as? [[String: String]] {
                let credentialIdentities: [ASPasswordCredentialIdentity] = credentialsData.compactMap {dict in
                    if let serviceIdentifier = dict["serviceIdentifier"], let userName = dict["userName"], let recordIdentifier = dict["recordIdentifier"] {
                        print("serviceIdentifier \(serviceIdentifier) userName \(userName) recordIdentifier \(recordIdentifier)")
                        
                        return ASPasswordCredentialIdentity(
                            serviceIdentifier: ASCredentialServiceIdentifier(identifier: serviceIdentifier, type: .URL),
                            user: userName,
                            recordIdentifier: recordIdentifier
                        )
                    } else {
                        return nil
                    }
                }
                
                let store = ASCredentialIdentityStore.shared
                store.getState{state in
                    if state.isEnabled {
                        ASCredentialIdentityStore.shared.saveCredentialIdentities(credentialIdentities, completion: {(saveResult, error) in
                            if error != nil {
                                result(nil)
                            } else {
                                result(saveResult)
                            }
                        }
                        )
                    } else {
                        result(nil)
                    }
                }
            } else {
                result(nil)
            }
        case "removeAllCredentials":
            let store = ASCredentialIdentityStore.shared
            store.getState{state in
                if state.isEnabled {
                    store.removeAllCredentialIdentities{(removeResult, error) in
                        if error != nil {
                            result(nil)
                        } else {
                            result(removeResult)
                        }
                    }
                } else {
                  result(nil)
              }
            }
        case "removeCredentials":
            guard let args = call.arguments as? [String: Any] else {
                result(nil)
                return
            }
            if let credentialsData = args["credentialsData"] as? [[String: String]] {
                let credentialIdentities: [ASPasswordCredentialIdentity] = credentialsData.compactMap {dict in
                    if let serviceIdentifier = dict["serviceIdentifier"], let userName = dict["userName"], let recordIdentifier = dict["recordIdentifier"] {
                        print("serviceIdentifier \(serviceIdentifier) userName \(userName) recordIdentifier \(recordIdentifier)")
                        
                        return ASPasswordCredentialIdentity(
                            serviceIdentifier: ASCredentialServiceIdentifier(identifier: serviceIdentifier, type: .URL),
                            user: userName,
                            recordIdentifier: recordIdentifier
                        )
                    } else {
                        return nil
                    }
                }
                let store = ASCredentialIdentityStore.shared
                store.getState{state in
                    if state.isEnabled {
                        store.removeCredentialIdentities(credentialIdentities){(removeResult, error) in
                            if error != nil {
                                result(nil)
                            } else {
                                result(removeResult)
                            }
                        }
                    } else {
                      result(nil)
                  }
                }
            }
        default:
            result(nil)
        }
    }
}
