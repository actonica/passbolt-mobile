import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let userDefaultsKey = "hasRunBefore"
    
    if UserDefaults.standard.bool(forKey: userDefaultsKey) == false {
      UserDefaults.standard.set(true, forKey: userDefaultsKey)
      let secItemClasses =  [
        kSecClassGenericPassword,
        kSecClassInternetPassword,
        kSecClassCertificate,
        kSecClassKey,
        kSecClassIdentity,
      ]
      for itemClass in secItemClasses {
        let spec: NSDictionary = [kSecClass: itemClass]
        SecItemDelete(spec)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
