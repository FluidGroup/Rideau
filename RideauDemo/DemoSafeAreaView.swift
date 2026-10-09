import Rideau
import UIKit

/// Visualizes the safe area UIKit delivers to the sheet's content view.
///
/// The green region is the content's own `safeAreaLayoutGuide`. The orange
/// region remains outside it. Measurements are read after layout and update
/// when the window, sheet size, or safe-area insets change.
final class DemoSafeAreaView: UIView, RideauContentType {

  private let safeRegionView = UIView()
  private let windowInsetLabel = UILabel()
  private let contentInsetLabel = UILabel()
  private let explanationLabel = UILabel()
  private var heightConstraint: NSLayoutConstraint!
  private var isExpanded = false

  init() {
    super.init(frame: .zero)

    backgroundColor = .systemBackground

    let excludedRegionView = UIView()
    excludedRegionView.backgroundColor = .systemOrange.withAlphaComponent(0.25)
    safeRegionView.backgroundColor = .systemBackground
    safeRegionView.layer.borderWidth = 2
    let safeTintView = UIView()
    safeTintView.backgroundColor = .systemTeal.withAlphaComponent(0.12)

    for region in [excludedRegionView, safeRegionView, safeTintView] {
      region.translatesAutoresizingMaskIntoConstraints = false
      region.isUserInteractionEnabled = false
    }
    addSubview(excludedRegionView)
    addSubview(safeRegionView)
    safeRegionView.addSubview(safeTintView)
    NSLayoutConstraint.activate([
      excludedRegionView.topAnchor.constraint(equalTo: topAnchor),
      excludedRegionView.bottomAnchor.constraint(equalTo: bottomAnchor),
      excludedRegionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      excludedRegionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      safeRegionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      safeRegionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      safeRegionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      safeRegionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      safeTintView.topAnchor.constraint(equalTo: safeRegionView.topAnchor),
      safeTintView.bottomAnchor.constraint(equalTo: safeRegionView.bottomAnchor),
      safeTintView.leadingAnchor.constraint(equalTo: safeRegionView.leadingAnchor),
      safeTintView.trailingAnchor.constraint(equalTo: safeRegionView.trailingAnchor),
    ])

    let titleLabel = UILabel()
    titleLabel.text = "Safe areaが内側に届く"
    titleLabel.font = .preferredFont(forTextStyle: .headline)
    titleLabel.adjustsFontForContentSizeCategory = true

    let legendLabel = UILabel()
    legendLabel.text = "緑：内容を置ける範囲\nオレンジ：避ける範囲"
    legendLabel.font = .preferredFont(forTextStyle: .subheadline)
    legendLabel.adjustsFontForContentSizeCategory = true
    legendLabel.numberOfLines = 0

    for label in [windowInsetLabel, contentInsetLabel] {
      label.font = UIFontMetrics(forTextStyle: .body).scaledFont(
        for: .monospacedSystemFont(ofSize: 17, weight: .semibold)
      )
      label.adjustsFontForContentSizeCategory = true
      label.numberOfLines = 0
    }
    windowInsetLabel.accessibilityIdentifier = "safe-area.window-right"
    contentInsetLabel.accessibilityIdentifier = "safe-area.content-right"

    explanationLabel.font = .preferredFont(forTextStyle: .footnote)
    explanationLabel.adjustsFontForContentSizeCategory = true
    explanationLabel.textColor = .secondaryLabel
    explanationLabel.numberOfLines = 0

    let resizeButton = UIButton(type: .system)
    var configuration = UIButton.Configuration.tinted()
    configuration.title = "高さを変える"
    configuration.image = UIImage(systemName: "arrow.up.and.down")
    configuration.imagePadding = 8
    configuration.baseForegroundColor = .systemTeal
    resizeButton.configuration = configuration
    resizeButton.accessibilityIdentifier = "safe-area.resize"
    resizeButton.addTarget(self, action: #selector(toggleHeight), for: .touchUpInside)

    let buttonRow = UIStackView(arrangedSubviews: [UIView(), resizeButton])
    let content = UIStackView(arrangedSubviews: [
      titleLabel,
      legendLabel,
      windowInsetLabel,
      contentInsetLabel,
      explanationLabel,
      buttonRow,
    ])
    content.axis = .vertical
    content.spacing = 10
    content.translatesAutoresizingMaskIntoConstraints = false
    addSubview(content)

    heightConstraint = heightAnchor.constraint(equalToConstant: 360)
    heightConstraint.priority = .defaultHigh
    NSLayoutConstraint.activate([
      heightConstraint,
      content.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
      content.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
      content.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
      content.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
    ])

    registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: DemoSafeAreaView, _: UITraitCollection) in
      view.setNeedsLayout()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    setNeedsLayout()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard !bounds.isEmpty else { return }
    safeRegionView.layer.borderColor = UIColor.systemTeal.resolvedColor(with: traitCollection).cgColor

    guard let window else { return }
    let rightInset = safeAreaInsets.right
    windowInsetLabel.text = "画面の右余白　\(points(window.safeAreaInsets.right))"
    contentInsetLabel.text = "内側の右余白　\(points(rightInset))"

    if rightInset > 0 {
      let frameInWindow = convert(bounds, to: window)
      let outerSpace = max(0, window.bounds.maxX - frameInWindow.maxX)
      explanationLabel.text = "シート外の\(points(outerSpace))を除いた残りが、内側に届いています。ボタンも緑の右端に配置。"
    } else {
      explanationLabel.text = "シートが安全な範囲内に収まるため、内側の右余白は0 ptです。"
    }
  }

  private func points(_ value: CGFloat) -> String {
    Double(value).formatted(.number.precision(.fractionLength(0...1))) + " pt"
  }

  @objc private func toggleHeight() {
    isExpanded.toggle()
    heightConstraint.constant = isExpanded ? 480 : 360
    requestRideauSelfSizingUpdate(
      animator: UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1, animations: nil)
    )
  }
}
