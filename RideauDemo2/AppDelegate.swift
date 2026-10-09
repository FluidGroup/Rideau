import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if #unavailable(iOS 13.0) {
      let newWindow = UIWindow()
      newWindow.rootViewController = RootContainerViewController()
      newWindow.makeKeyAndVisible()
      self.window = newWindow
    }
    return true
  }

  @available(iOS 13.0, *)
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: "Demo", sessionRole: connectingSceneSession.role)
    configuration.delegateClass = DemoSceneDelegate.self
    return configuration
  }
}

/// Keeps the demo attached to the active scene as the device opens and closes.
@available(iOS 13.0, *)
final class DemoSceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = RootContainerViewController()
    window.makeKeyAndVisible()
    self.window = window
  }
}
