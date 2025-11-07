//
//  HorizontalDial.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/07.
//

import SwiftUI
import UIKit

// MARK: - UIKit Component
class SnapDialView: UIScrollView, UIGestureRecognizerDelegate {
    // スクロール終了後のonScrollEnd遅延呼び出し用
    var scrollEndDelay: TimeInterval = 1.2
    private var scrollEndWorkItem: DispatchWorkItem?
    // ...existing code...

    // MARK: - Properties
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var childViews: [UIView] = []
    private var currentCenteredIndex: Int = -1
    private var previousBounds: CGRect = .zero
    private var isUserScrolling: Bool = false

    // Configuration
    var animationDuration: TimeInterval = 0.3

    // Callbacks
    var onCenteredItemChanged: ((Int) -> Void)?
    var onScrollBegin: (() -> Void)?
    var onScrollEnd: ((Int) -> Void)?
    var onTap: ((Int) -> Void)?
    var onDistanceChanged: ((Int, CGFloat) -> Void)?  // (index, distance from center)

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isPagingEnabled = false
        bounces = true
        decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.0)
        delegate = self

        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Check if bounds changed (width changed)
        let boundsChanged = previousBounds.size != bounds.size

        if boundsChanged && previousBounds != .zero && currentCenteredIndex >= 0 {
            // Calculate the current scroll position relative to centered item
            let oldCenterX = contentOffset.x + previousBounds.width / 2

            // Update content insets for new bounds
            updateContentInsets()

            // Calculate new scroll position to maintain visual position
            let newCenterX = contentOffset.x + bounds.width / 2
            let adjustment = oldCenterX - newCenterX

            // Adjust content offset to compensate for width change
            contentOffset.x += adjustment
        } else {
            updateContentInsets()
        }

        previousBounds = bounds
    }

    private func updateContentInsets() {
        // Add padding so that the center of edge items can align with screen center
        guard let firstView = contentStackView.arrangedSubviews.first else { return }

        // Calculate padding: (scrollView width / 2) - (item width / 2)
        // This centers the edge items perfectly
        let itemWidth = firstView.bounds.width
        let horizontalPadding = (bounds.width - itemWidth) / 2

        contentInset = UIEdgeInsets(
            top: 0,
            left: horizontalPadding,
            bottom: 0,
            right: horizontalPadding
        )

        // Adjust content offset to account for the inset if needed
        // This prevents the content from appearing shifted initially
        if contentOffset.x == 0 && childViews.count > 0 {
            contentOffset.x = -horizontalPadding
        }
    }

    // MARK: - Public Methods
    func setChildViews(_ views: [UIView]) {
        // Remove existing views
        childViews.forEach { $0.removeFromSuperview() }
        childViews.removeAll()
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new views
        childViews = views
        views.enumerated().forEach { index, view in
            contentStackView.addArrangedSubview(view)

            // Add tap gesture to each view
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
            view.tag = index

            // Add long press gesture for highlight effect
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPressGesture.minimumPressDuration = 0.0
            longPressGesture.delegate = self
            view.addGestureRecognizer(longPressGesture)
        }

        layoutIfNeeded()
        updateContentInsets()
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        let index = tappedView.tag

        // Notify the tap callback
        onTap?(index)

        // Scroll to the tapped index
        scrollToIndex(index, animated: true)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let pressedView = gesture.view else { return }

        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
                pressedView.alpha = 0.75
                pressedView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
                pressedView.alpha = 1.0
                pressedView.transform = .identity
            }
        default:
            break
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow tap and long press gestures to work together
        return true
    }

    func scrollToIndex(_ index: Int, animated: Bool = false) {
        guard index >= 0 && index < contentStackView.arrangedSubviews.count else { return }

        let targetView = contentStackView.arrangedSubviews[index]
        let targetCenterX = targetView.frame.midX
        let targetOffsetX = targetCenterX - bounds.width / 2

        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                self.contentOffset.x = targetOffsetX
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                // アニメーション完了後に遅延してonScrollEndを呼ぶ
                let workItem = DispatchWorkItem { [weak self] in
                    self?.onScrollEnd?(index)
                }
                self.scrollEndWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + self.scrollEndDelay, execute: workItem)
            })
        } else {
            contentOffset.x = targetOffsetX
        }
    }

    func setSpacing(_ spacing: CGFloat) {
        contentStackView.spacing = spacing
    }

    func setDistribution(_ distribution: UIStackView.Distribution) {
        contentStackView.distribution = distribution
    }

    // MARK: - Private Methods
    private func updateCenteredItem() {
        guard !childViews.isEmpty else { return }

        // Calculate the center point of the scroll view
        let centerX = contentOffset.x + bounds.width / 2

        // Find the view closest to the center
        var closestIndex = 0
        var minDistance = CGFloat.greatestFiniteMagnitude

        for (index, view) in contentStackView.arrangedSubviews.enumerated() {
            let viewCenterX = view.frame.midX
            let distance = abs(viewCenterX - centerX)

            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }

        // Only notify if the centered item changed
        if closestIndex != currentCenteredIndex {
            currentCenteredIndex = closestIndex
            onCenteredItemChanged?(closestIndex)
        }
    }

    private func snapToCenter(animated: Bool = true) {
        guard !contentStackView.arrangedSubviews.isEmpty else { return }

        // Calculate the center point of the scroll view
        let centerX = contentOffset.x + bounds.width / 2

        // Find the view closest to the center
        var closestView: UIView?
        var closestIndex = 0
        var minDistance = CGFloat.greatestFiniteMagnitude

        for (index, view) in contentStackView.arrangedSubviews.enumerated() {
            let viewCenterX = view.frame.midX
            let distance = abs(viewCenterX - centerX)

            if distance < minDistance {
                minDistance = distance
                closestView = view
                closestIndex = index
            }
        }

        guard let targetView = closestView else { return }

        // Calculate the target offset to center this view
        let targetCenterX = targetView.frame.midX
        let targetOffsetX = targetCenterX - bounds.width / 2

        // Animate to the target position
        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                self.contentOffset.x = targetOffsetX
            }, completion: { _ in
                // Call the scroll end callback with the final centered index
                self.onScrollEnd?(closestIndex)
            })
        } else {
            contentOffset.x = targetOffsetX
            // Call the scroll end callback immediately for non-animated snaps
            onScrollEnd?(closestIndex)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SnapDialView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
        // スクロール開始時に全てのchildViewsのalpha/transformを元に戻す
        for view in childViews {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
                view.alpha = 1.0
                view.transform = .identity
            }
        }
        onScrollBegin?()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCenteredItem()
        // スクロール中に再度呼ばれたら前のWorkItemをキャンセル
        scrollEndWorkItem?.cancel()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Find and notify the final centered index
        guard !contentStackView.arrangedSubviews.isEmpty else { return }

        let centerX = contentOffset.x + bounds.width / 2
        var closestIndex = 0
        var minDistance = CGFloat.greatestFiniteMagnitude

        for (index, view) in contentStackView.arrangedSubviews.enumerated() {
            let viewCenterX = view.frame.midX
            let distance = abs(viewCenterX - centerX)

            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }

        isUserScrolling = false
        // 遅延してonScrollEndを呼ぶ
        let workItem = DispatchWorkItem { [weak self] in
            self?.onScrollEnd?(closestIndex)
        }
        scrollEndWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + scrollEndDelay, execute: workItem)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // Find and notify the final centered index
            guard !contentStackView.arrangedSubviews.isEmpty else { return }

            let centerX = contentOffset.x + bounds.width / 2
            var closestIndex = 0
            var minDistance = CGFloat.greatestFiniteMagnitude

            for (index, view) in contentStackView.arrangedSubviews.enumerated() {
                let viewCenterX = view.frame.midX
                let distance = abs(viewCenterX - centerX)

                if distance < minDistance {
                    minDistance = distance
                    closestIndex = index
                }
            }

            isUserScrolling = false
            // 遅延してonScrollEndを呼ぶ
            let workItem = DispatchWorkItem { [weak self] in
                self?.onScrollEnd?(closestIndex)
            }
            scrollEndWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + scrollEndDelay, execute: workItem)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Calculate where the scroll would naturally end
        let targetX = targetContentOffset.pointee.x + bounds.width / 2

        // Find the closest view to that position
        var closestView: UIView?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for view in contentStackView.arrangedSubviews {
            let viewCenterX = view.frame.midX
            let distance = abs(viewCenterX - targetX)

            if distance < minDistance {
                minDistance = distance
                closestView = view
            }
        }

        // Update target offset to center the closest view
        if let targetView = closestView {
            let targetCenterX = targetView.frame.midX
            targetContentOffset.pointee.x = targetCenterX - bounds.width / 2
        }
    }
}

// MARK: - SwiftUI Wrapper
struct SnapDial<Content: View>: UIViewRepresentable {
    let content: [Content]
    var spacing: CGFloat = 12
    var distribution: UIStackView.Distribution = .fillEqually
    var animationDuration: TimeInterval = 0.3
    @Binding var centeredIndex: Int
    var initialIndex: Int = 0
    var onScrollBegin: (() -> Void)?
    var onScrollEnd: ((Int) -> Void)?
    var onTap: ((Int) -> Void)?
    var onDistanceChanged: ((Int, CGFloat) -> Void)?

    init(
        spacing: CGFloat = 0,
        distribution: UIStackView.Distribution = .fillEqually,
        animationDuration: TimeInterval = 0.3,
        centeredIndex: Binding<Int> = .constant(-1),
        initialIndex: Int = 0,
        onScrollBegin: (() -> Void)? = nil,
        onScrollEnd: ((Int) -> Void)? = nil,
        onTap: ((Int) -> Void)? = nil,
        onDistanceChanged: ((Int, CGFloat) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = [content()]
        self.spacing = spacing
        self.distribution = distribution
        self.animationDuration = animationDuration
        self._centeredIndex = centeredIndex
        self.initialIndex = initialIndex
        self.onScrollBegin = onScrollBegin
        self.onScrollEnd = onScrollEnd
        self.onTap = onTap
        self.onDistanceChanged = onDistanceChanged
    }

    init(
        spacing: CGFloat = 0,
        distribution: UIStackView.Distribution = .fillEqually,
        animationDuration: TimeInterval = 0.3,
        centeredIndex: Binding<Int> = .constant(-1),
        initialIndex: Int = 0,
        onScrollBegin: (() -> Void)? = nil,
        onScrollEnd: ((Int) -> Void)? = nil,
        onTap: ((Int) -> Void)? = nil,
        onDistanceChanged: ((Int, CGFloat) -> Void)? = nil,
        content: [Content]
    ) {
        self.content = content
        self.spacing = spacing
        self.distribution = distribution
        self.animationDuration = animationDuration
        self._centeredIndex = centeredIndex
        self.initialIndex = initialIndex
        self.onScrollBegin = onScrollBegin
        self.onScrollEnd = onScrollEnd
        self.onTap = onTap
        self.onDistanceChanged = onDistanceChanged
    }

    func makeUIView(context: Context) -> SnapDialView {
        let dialView = SnapDialView()
        dialView.setSpacing(spacing)
        dialView.setDistribution(distribution)
        dialView.animationDuration = animationDuration

        dialView.onCenteredItemChanged = { [weak dialView] index in
            DispatchQueue.main.async {
                self.centeredIndex = index
            }
        }

        dialView.onScrollBegin = {
            DispatchQueue.main.async {
                self.onScrollBegin?()
            }
        }

        dialView.onScrollEnd = { index in
            DispatchQueue.main.async {
                self.onScrollEnd?(index)
            }
        }

        dialView.onTap = { index in
            DispatchQueue.main.async {
                self.onTap?(index)
                self.centeredIndex = index
            }
        }

        dialView.onDistanceChanged = { index, distance in
            DispatchQueue.main.async {
                self.onDistanceChanged?(index, distance)
            }
        }

        return dialView
    }

    func updateUIView(_ uiView: SnapDialView, context: Context) {
        // Only update if the content count changed or if views haven't been set yet
        if context.coordinator.viewCount != content.count {
            context.coordinator.viewCount = content.count

            // Convert SwiftUI views to UIKit views and store hosting controllers
            context.coordinator.hostingControllers = content.map { view in
                let controller = UIHostingController(rootView: view)
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                controller.view.backgroundColor = .clear
                return controller
            }

            let views = context.coordinator.hostingControllers.map { $0.view! }
            uiView.setChildViews(views)

            // Scroll to initial index after setting views
            if !context.coordinator.didSetInitialIndex {
                context.coordinator.didSetInitialIndex = true
                // Use asyncAfter to ensure layout is complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    uiView.scrollToIndex(self.initialIndex, animated: false)
                }
            }
        } else {
            // Update existing hosting controllers with new content
            for (index, controller) in context.coordinator.hostingControllers.enumerated() {
                if index < content.count {
                    controller.rootView = content[index]
                }
            }
        }

        uiView.setSpacing(spacing)
        uiView.setDistribution(distribution)
        uiView.animationDuration = animationDuration

        // Update callbacks
        uiView.onCenteredItemChanged = { [weak uiView] index in
            DispatchQueue.main.async {
                self.centeredIndex = index
            }
        }

        uiView.onScrollBegin = {
            DispatchQueue.main.async {
                self.onScrollBegin?()
            }
        }

        uiView.onScrollEnd = { index in
            DispatchQueue.main.async {
                self.onScrollEnd?(index)
            }
        }

        uiView.onTap = { index in
            DispatchQueue.main.async {
                self.onTap?(index)
                self.centeredIndex = index
            }
        }

        uiView.onDistanceChanged = { index, distance in
            DispatchQueue.main.async {
                self.onDistanceChanged?(index, distance)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var viewCount: Int = 0
        var didSetInitialIndex: Bool = false
        var hostingControllers: [UIHostingController<Content>] = []
    }
}

// MARK: - Convenience Initializer for Array of Views
extension SnapDial {
    init<Data: RandomAccessCollection>(
        _ data: Data,
        spacing: CGFloat = 4,
        distribution: UIStackView.Distribution = .fillEqually,
        animationDuration: TimeInterval = 0.3,
        centeredIndex: Binding<Int> = .constant(-1),
        initialIndex: Int = 0,
        onScrollBegin: (() -> Void)? = nil,
        onScrollEnd: ((Int) -> Void)? = nil,
        onTap: ((Int) -> Void)? = nil,
        onDistanceChanged: ((Int, CGFloat) -> Void)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.content = data.map(content)
        self.spacing = spacing
        self.distribution = distribution
        self.animationDuration = animationDuration
        self._centeredIndex = centeredIndex
        self.initialIndex = initialIndex
        self.onScrollBegin = onScrollBegin
        self.onScrollEnd = onScrollEnd
        self.onTap = onTap
        self.onDistanceChanged = onDistanceChanged
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var centeredIndex: Int = -1
    @Previewable @State var scrollBegan: Bool = false

    let animationDuration: Double = 0.2

    VStack {
        Spacer()
        SnapDial(
            0..<8,
            distribution: .fill,
            animationDuration: animationDuration,
            centeredIndex: $centeredIndex,
            initialIndex: 1,
            onScrollBegin: {
                scrollBegan = true
            },
            onScrollEnd: { _ in
                scrollBegan = false
            },
            onTap: { index in
                print("Tapped index: \(index)")
            }
        ) { index in
            let isSelected = index == centeredIndex

            Text("\(index + 1)")
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color(.systemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
                .scaleEffect(isSelected ? 1.0 : 0.9)
                .animation(.spring(response: animationDuration), value: isSelected)
        }
        .frame(height: 54)
        .frame(maxWidth: scrollBegan ? .infinity : 240)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .animation(.spring(response: animationDuration), value: scrollBegan)
        Spacer()
    }
    .padding()
}
