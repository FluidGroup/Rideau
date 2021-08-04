import UIKit

extension NSLayoutConstraint {

  @discardableResult
  func setInternalIdentifier(_ string: String) -> NSLayoutConstraint {
    self.identifier = "BoxLayout." + string
    return self
  }

  @discardableResult
  func setIdentifier(_ string: String) -> NSLayoutConstraint {
    self.identifier = string
    return self
  }

  @discardableResult
  func setPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
    self.priority = priority
    return self
  }

}
