import Rideau
import SwiftUI
import UIKit

/// A sheet body that changes its intrinsic height via `requestRideauSelfSizingUpdate`.
final class DemoExpandableView: UIView, RideauContentType {
  private var heightConstraint: NSLayoutConstraint!

  init() {
    super.init(frame: .zero)

    heightConstraint = heightAnchor.constraint(equalToConstant: 120)
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true

    backgroundColor = .systemTeal

    let expandButton = UIButton(type: .system)
    expandButton.setTitle("Expand", for: .normal)
    expandButton.addTarget(self, action: #selector(expand), for: .touchUpInside)

    let shrinkButton = UIButton(type: .system)
    shrinkButton.setTitle("Shrink", for: .normal)
    shrinkButton.addTarget(self, action: #selector(shrink), for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [expandButton, shrinkButton])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 12

    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  @objc private func expand() {
    heightConstraint.constant = 300
    requestRideauSelfSizingUpdate(
      animator: UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1, animations: nil)
    )
  }

  @objc private func shrink() {
    heightConstraint.constant = 120
    requestRideauSelfSizingUpdate(
      animator: UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1, animations: nil)
    )
  }
}

final class DemoTextInputView: UIView {
  init() {
    super.init(frame: .zero)
    backgroundColor = .systemPurple

    let textView = UITextView()
    textView.backgroundColor = UIColor(white: 1, alpha: 0.9)
    textView.font = .preferredFont(forTextStyle: .body)

    textView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(textView)
    NSLayoutConstraint.activate([
      textView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
      textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
      textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
      textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
}

/// Visualises how the sheet resizes: outer pink fills the sheet, inner orange is inset by 20pt.
final class ResizingVisualizerView: UIView {
  init() {
    super.init(frame: .zero)
    backgroundColor = .systemPink

    let inner = UIView.mockBlock(color: .systemOrange)
    inner.translatesAutoresizingMaskIntoConstraints = false
    addSubview(inner)
    NSLayoutConstraint.activate([
      inner.topAnchor.constraint(equalTo: topAnchor, constant: 20),
      inner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
      inner.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      inner.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
}

final class DemoBlankView: UIView {
  init(color: UIColor) {
    super.init(frame: .zero)
    backgroundColor = color
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
}

/// Hosts a SwiftUI view so it can be used as Rideau body content.
final class SwiftUIWrapperView<Content: View>: UIView {
  private let hosting: UIHostingController<Content>

  init(content: Content) {
    self.hosting = UIHostingController(rootView: content)
    super.init(frame: .zero)

    hosting.view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hosting.view)
    NSLayoutConstraint.activate([
      hosting.view.topAnchor.constraint(equalTo: topAnchor),
      hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor),
      hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
}

struct ListContentView: View {
  var body: some View {
    ZStack {
      Color(.systemBackground).ignoresSafeArea()
      VStack(spacing: 0) {
        Rectangle()
          .frame(height: 64)
          .foregroundColor(Color(.systemGray5))
          .overlay(Text("Header").font(.headline))

        ScrollView {
          LazyVStack(spacing: 1) {
            ForEach(0..<30) { i in
              Rectangle()
                .frame(height: 80)
                .foregroundColor(Color(.systemGray6))
                .overlay(Text("Row \(i)"))
            }
          }
        }
      }
    }
  }
}

struct XYScrollableContentView: View {
  var body: some View {
    ZStack {
      Color(.systemBackground).ignoresSafeArea()
      ScrollView(.vertical) {
        VStack(spacing: 20) {
          TextField("Text", text: .constant("Hello"))
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 20)
            .frame(height: 48)

          ForEach(0..<6) { section in
            VStack(alignment: .leading, spacing: 8) {
              Text("Section \(section)").font(.headline).padding(.leading, 20)
              ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 12) {
                  ForEach(0..<10) { _ in
                    RoundedRectangle(cornerRadius: 8)
                      .frame(width: 100, height: 100)
                      .foregroundColor(Color(.systemGray5))
                  }
                }
                .padding(.horizontal, 20)
              }
            }
          }
        }
        .padding(.vertical, 20)
      }
    }
  }
}
