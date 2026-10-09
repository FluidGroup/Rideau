import StorybookKit
import SwiftUI

@main
struct RideauDemoApp: App {
  private let launchRequest = StorybookLaunchRequest(arguments: ProcessInfo.processInfo.arguments) ?? .catalog

  var body: some Scene {
    WindowGroup {
      Storybook(launchRequest: launchRequest)
    }
  }
}
