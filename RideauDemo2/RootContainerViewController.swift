import StorybookKit
import SwiftUI

/// Displays the preview catalog and honors source-qualified Storybook launch requests.
final class RootContainerViewController: UIHostingController<Storybook> {

  init() {
    let request = StorybookLaunchRequest(arguments: ProcessInfo.processInfo.arguments) ?? .catalog
    super.init(rootView: Storybook(launchRequest: request))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
