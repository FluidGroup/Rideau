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
      hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      hosting.view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
}

/// SwiftUI-hosted content whose intrinsic height is observed by `.autoPointsFromBottom`.
final class SwiftUIAutoSizingDemoView: UIView {
  private let hosting: UIHostingController<AutoSizingSwiftUIContentView>

  init() {
    self.hosting = UIHostingController(rootView: AutoSizingSwiftUIContentView())
    super.init(frame: .zero)

    if #available(iOS 16.0, *) {
      hosting.sizingOptions = .intrinsicContentSize
    }

    hosting.view.backgroundColor = .clear
    hosting.view.translatesAutoresizingMaskIntoConstraints = false
    hosting.view.setContentHuggingPriority(.defaultLow, for: .vertical)
    hosting.view.setContentCompressionResistancePriority(.required, for: .vertical)

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

private struct AutoSizingSwiftUIContentView: View {
  @State private var isExpanded = false

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("SwiftUI AutoPoints")
          .font(.headline)
        Spacer()
        Text(isExpanded ? "Expanded" : "Compact")
          .font(.caption)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(Color(.secondarySystemBackground))
          .clipShape(Capsule())
      }

      Text("Tap the button and confirm the .autoPointsFromBottom snap point follows this SwiftUI view's fitted height.")
        .font(.subheadline)
        .foregroundColor(.secondary)

      Button(isExpanded ? "Shrink SwiftUI content" : "Expand SwiftUI content") {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
          isExpanded.toggle()
        }
      }

      if isExpanded {
        VStack(spacing: 8) {
          ForEach(0..<4) { index in
            HStack(spacing: 12) {
              Circle()
                .fill(Color(.systemTeal))
                .frame(width: 10, height: 10)
              Text("SwiftUI row \(index + 1)")
                .font(.body)
              Spacer()
            }
            .padding(12)
            .background(Color(.systemBackground).opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
          }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
      }

      Spacer(minLength: 0)
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .fill(
          LinearGradient(
            colors: [
              Color(.systemTeal).opacity(0.25),
              Color(.systemBlue).opacity(0.12),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
    )
    .overlay(
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .stroke(Color(.separator), lineWidth: 1)
    )
    .padding(16)
    .background(
      GeometryReader { proxy in
        Color.clear
          .overlay(alignment: .bottomTrailing) {
            Text("SwiftUI content height: \(Int(proxy.size.height))pt")
              .font(.caption2)
              .foregroundColor(.secondary)
              .padding(8)
          }
      }
    )
  }
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

struct MixedAxisScrollContentView: View {
  var body: some View {
    ZStack {
      Color(.systemBackground).ignoresSafeArea()
      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 24) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Mixed Scroll Demo")
              .font(.title2.weight(.semibold))
            Text("Vertical scrolling with horizontal carousels inside Rideau.")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)

          TextField("Search", text: .constant("Rideau"))
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 20)
            .frame(height: 48)

          ForEach(0..<6) { section in
            VStack(alignment: .leading, spacing: 10) {
              Text("Horizontal Section \(section + 1)")
                .font(.headline)
                .padding(.horizontal, 20)

              ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 12) {
                  ForEach(0..<10) { item in
                    VStack(alignment: .leading, spacing: 8) {
                      RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                        .frame(width: 160, height: 100)
                        .overlay(
                          Text("Card \(item + 1)")
                            .font(.headline)
                        )

                      Text("Description \(section + 1)-\(item + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(width: 160)
                  }
                }
                .padding(.horizontal, 20)
              }
            }
          }

          VStack(spacing: 12) {
            ForEach(0..<8) { row in
              RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 72)
                .overlay(
                  HStack {
                    Text("Vertical Row \(row + 1)")
                      .font(.headline)
                    Spacer()
                  }
                  .padding(.horizontal, 20)
                )
                .padding(.horizontal, 20)
            }
          }

          Spacer(minLength: 24)
        }
      }
    }
  }
}
