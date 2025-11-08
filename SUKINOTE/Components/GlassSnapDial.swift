import SwiftUI
//  GlassSnapDial.swift
//  SUKINOTE
//
//  Auto-generated duplicate of SnapDialView for experimentation.
//
import UIKit

// Model representing an item in GlassSnapDial
struct GlassSnapDialItem {
    let icon: UIImage  // Base (deselected) icon
    let label: String  // Text label
    let highlightColor: UIColor  // Selected-state tint color
    let highlightedIcon: UIImage?  // Optional alternate icon when selected

    init(
        icon: UIImage,
        label: String,
        highlightColor: UIColor = .label,
        highlightedIcon: UIImage? = nil
    ) {
        self.icon = icon
        self.label = label
        self.highlightColor = highlightColor
        self.highlightedIcon = highlightedIcon
    }
}

class GlassSnapDial: UIScrollView, UIGestureRecognizerDelegate {
    // Delayed onScrollEnd invocation
    var scrollEndDelay: TimeInterval = 0.8
    private var scrollEndWorkItem: DispatchWorkItem?

    // MARK: - Properties
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        // Center arranged subviews vertically so they auto-center within given frame height
        stack.alignment = .center
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var childViews: [UIView] = []
    private var currentCenteredIndex: Int = -1
    private var previousBounds: CGRect = .zero
    private var isUserScrolling: Bool = false
    // Keep references to per-item views to animate selection changes
    private struct ItemComponents {
        let container: UIView
        let imageView: UIImageView
        let label: UILabel
        let heightConstraint: NSLayoutConstraint
        let baseIcon: UIImage
        let highlightedIcon: UIImage?
        let highlightColor: UIColor
    }
    private var itemComponents: [ItemComponents] = []

    // Configuration
    var animationDuration: TimeInterval = 0.3
    // Selection appearance configuration
    var deselectedItemHeight: CGFloat = 52
    var selectedItemHeight: CGFloat = 60
    var deselectedTintColor: UIColor = .label
    var selectedTintColor: UIColor = .systemBlue
    var deselectedBackgroundColor: UIColor = .clear
    var selectedBackgroundColor: UIColor = UIColor.systemBlue
        .withAlphaComponent(0.12)
    var selectionAnimationDuration: TimeInterval = 0.22
    var selectedScale: CGFloat = 1.08
    var deselectedScale: CGFloat = 1.0
    // Extra height applied to selected item compared to deselected height
    var selectedHeightExtra: CGFloat = 8
    // Haptics
    var hapticsEnabled: Bool = true
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

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
            contentStackView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let boundsChanged = previousBounds.size != bounds.size

        if boundsChanged && previousBounds != .zero && currentCenteredIndex >= 0
        {
            let oldCenterX = contentOffset.x + previousBounds.width / 2
            updateContentInsets()
            let newCenterX = contentOffset.x + bounds.width / 2
            let adjustment = oldCenterX - newCenterX
            contentOffset.x += adjustment
        } else {
            updateContentInsets()
        }

        previousBounds = bounds
    }

    private func updateContentInsets() {
        guard let firstView = contentStackView.arrangedSubviews.first else {
            return
        }
        let itemWidth = firstView.bounds.width
        let horizontalPadding = (bounds.width - itemWidth) / 2
        contentInset = UIEdgeInsets(
            top: 0,
            left: horizontalPadding,
            bottom: 0,
            right: horizontalPadding
        )
        if contentOffset.x == 0 && childViews.count > 0 {
            contentOffset.x = -horizontalPadding
        }
    }

    // MARK: - Public Methods
    /// Build dial from item models (icon + label)
    /// - Parameters:
    ///   - items: Array of GlassSnapDialItem
    ///   - itemSize: Size for each item view
    ///   - font: Font for label
    ///   - tintColor: Tint color for icon and text
    ///   - spacing: Horizontal spacing between items
    public func setItems(
        _ items: [GlassSnapDialItem],
        itemSize: CGSize = CGSize(width: 44, height: 52),
        font: UIFont = .systemFont(ofSize: 12, weight: .semibold),
        tintColor: UIColor = .label,
        spacing: CGFloat = 8,
        centerVertically: Bool = true
    ) {
        // Sync heights from itemSize; highlight (container) height equals itemSize.height for all states
        deselectedItemHeight = itemSize.height
        selectedItemHeight = deselectedItemHeight  // no extra height for selected

        // Build item views and keep references for selection styling
        itemComponents.removeAll()
        let views: [UIView] = items.map { item in
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = deselectedBackgroundColor
            container.layer.cornerRadius = 12
            container.clipsToBounds = true

            let vStack = UIStackView()
            vStack.axis = .vertical
            vStack.alignment = .center
            vStack.spacing = 2
            vStack.translatesAutoresizingMaskIntoConstraints = false

            let imageView = UIImageView(
                image: item.icon.withRenderingMode(.alwaysTemplate)
            )
            imageView.tintColor = tintColor
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = item.label
            label.font = font
            label.textColor = tintColor
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            vStack.addArrangedSubview(imageView)
            vStack.addArrangedSubview(label)
            container.addSubview(vStack)

            let heightConstraint = container.heightAnchor.constraint(
                equalToConstant: deselectedItemHeight
            )

            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(
                    equalToConstant: itemSize.width
                ),
                heightConstraint,
                vStack.centerXAnchor.constraint(
                    equalTo: container.centerXAnchor
                ),
                vStack.centerYAnchor.constraint(
                    equalTo: container.centerYAnchor
                ),
                imageView.widthAnchor.constraint(
                    equalTo: container.widthAnchor,
                    multiplier: 0.4
                ),
                imageView.heightAnchor.constraint(
                    equalTo: imageView.widthAnchor
                ),
            ])

            itemComponents.append(
                ItemComponents(
                    container: container,
                    imageView: imageView,
                    label: label,
                    heightConstraint: heightConstraint,
                    baseIcon: item.icon,
                    highlightedIcon: item.highlightedIcon,
                    highlightColor: item.highlightColor
                )
            )
            return container
        }

        contentStackView.alignment = centerVertically ? .center : .fill
        setSpacing(spacing)
        setChildViews(views)
        // Apply initial selection style
        applySelectionStyles(animated: false)
    }

    func setChildViews(_ views: [UIView]) {
        childViews.forEach { $0.removeFromSuperview() }
        childViews.removeAll()
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        childViews = views
        views.enumerated().forEach { index, view in
            contentStackView.addArrangedSubview(view)
            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap(_:))
            )
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
            view.tag = index
            let longPressGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress(_:))
            )
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
        onTap?(index)
        scrollToIndex(index, animated: true)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer)
    {
        guard let pressedView = gesture.view else { return }
        switch gesture.state {
        case .began:
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [.allowUserInteraction, .curveEaseOut]
            ) {
                pressedView.alpha = 0.75
                pressedView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        case .ended, .cancelled, .failed:
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: [.allowUserInteraction, .curveEaseOut]
            ) {
                pressedView.alpha = 1.0
                pressedView.transform = .identity
            }
        default:
            break
        }
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer:
            UIGestureRecognizer
    ) -> Bool {
        return true
    }

    func scrollToIndex(_ index: Int, animated: Bool = false) {
        guard index >= 0 && index < contentStackView.arrangedSubviews.count
        else { return }
        let targetView = contentStackView.arrangedSubviews[index]
        let targetCenterX = targetView.frame.midX
        let targetOffsetX = targetCenterX - bounds.width / 2
        if animated {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    self.contentOffset.x = targetOffsetX
                },
                completion: { [weak self] _ in
                    guard let self = self else { return }
                    let workItem = DispatchWorkItem { [weak self] in
                        self?.onScrollEnd?(index)
                    }
                    self.scrollEndWorkItem = workItem
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + self.scrollEndDelay,
                        execute: workItem
                    )
                }
            )
        } else {
            contentOffset.x = targetOffsetX
        }
    }

    func setSpacing(_ spacing: CGFloat) { contentStackView.spacing = spacing }

    func setDistribution(_ distribution: UIStackView.Distribution) {
        contentStackView.distribution = distribution
    }

    private func updateCenteredItem() {
        guard !childViews.isEmpty else { return }
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
        if closestIndex != currentCenteredIndex {
            currentCenteredIndex = closestIndex
            onCenteredItemChanged?(closestIndex)
            applySelectionStyles(animated: true)
            if hapticsEnabled {
                selectionFeedbackGenerator.selectionChanged()
                selectionFeedbackGenerator.prepare()
            }
        }
    }
}

// MARK: - Selection Styling
extension GlassSnapDial {
    /// Blend a color with white to create a lighter, opaque version
    private func blendWithWhite(_ color: UIColor, amount: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Blend with white
        let blendedRed = red + (1.0 - red) * amount
        let blendedGreen = green + (1.0 - green) * amount
        let blendedBlue = blue + (1.0 - blue) * amount

        return UIColor(red: blendedRed, green: blendedGreen, blue: blendedBlue, alpha: 1.0)
    }

    fileprivate func applySelectionStyles(animated: Bool) {
        guard !itemComponents.isEmpty else { return }
        let changes = {
            for (index, comp) in self.itemComponents.enumerated() {
                let selected = index == self.currentCenteredIndex
                // Keep highlight (background container) height constant regardless of selection
                comp.heightConstraint.constant = self.deselectedItemHeight
                if selected {
                    // Mix highlightColor with white to create a light, opaque background
                    let lightTint = self.blendWithWhite(comp.highlightColor, amount: 0.85)
                    comp.container.backgroundColor = lightTint
                } else {
                    comp.container.backgroundColor =
                        self.deselectedBackgroundColor
                }
                // Icon swap if highlighted icon provided (keep template so tint applies)
                if selected, let hi = comp.highlightedIcon {
                    comp.imageView.image = hi.withRenderingMode(.alwaysTemplate)
                } else {
                    comp.imageView.image = comp.baseIcon.withRenderingMode(
                        .alwaysTemplate
                    )
                }
                let tint =
                    selected ? comp.highlightColor : self.deselectedTintColor
                comp.imageView.tintColor = tint
                comp.label.textColor = tint
                // No scaling: keep highlight width and height exactly matching itemSize
                comp.container.transform = .identity
            }
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(
                withDuration: selectionAnimationDuration,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: changes,
                completion: nil
            )
        } else {
            changes()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension GlassSnapDial: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
        for view in childViews {
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: [.allowUserInteraction, .curveEaseOut]
            ) {
                view.alpha = 1.0
                view.transform = .identity
            }
        }
        onScrollBegin?()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCenteredItem()
        scrollEndWorkItem?.cancel()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
        let workItem = DispatchWorkItem { [weak self] in
            self?.onScrollEnd?(closestIndex)
        }
        scrollEndWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + scrollEndDelay,
            execute: workItem
        )
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            guard !contentStackView.arrangedSubviews.isEmpty else { return }
            let centerX = contentOffset.x + bounds.width / 2
            var closestIndex = 0
            var minDistance = CGFloat.greatestFiniteMagnitude
            for (index, view) in contentStackView.arrangedSubviews.enumerated()
            {
                let viewCenterX = view.frame.midX
                let distance = abs(viewCenterX - centerX)
                if distance < minDistance {
                    minDistance = distance
                    closestIndex = index
                }
            }
            isUserScrolling = false
            let workItem = DispatchWorkItem { [weak self] in
                self?.onScrollEnd?(closestIndex)
            }
            scrollEndWorkItem = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + scrollEndDelay,
                execute: workItem
            )
        }
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let targetX = targetContentOffset.pointee.x + bounds.width / 2
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
        if let targetView = closestView {
            let targetCenterX = targetView.frame.midX
            targetContentOffset.pointee.x = targetCenterX - bounds.width / 2
        }
    }
}

// MARK: - SwiftUI Wrapper
struct GlassSnapDialView: View {
    // Data
    var items: [GlassSnapDialItem]

    // Appearance/behavior
    var spacing: CGFloat = 0
    var itemSize: CGSize = CGSize(width: 44, height: 40)
    var font: UIFont = .systemFont(ofSize: 12, weight: .semibold)
    var tintColor: UIColor = .label
    var animationDuration: TimeInterval = 0.3
    var scrollEndDelay: TimeInterval = 0.8
    var hapticsEnabled: Bool = true

    // Compact width control (managed inside this view)
    var compactEnabled: Bool = true
    var initialCompact: Bool = true
    var compactWidth: CGFloat = 240
    var collapseDelayAfterTap: TimeInterval = 1.5

    // Optional: render with Button(.glass) style as a non-interactive background
    var useButtonGlassBackground: Bool = false
    var buttonCornerRadius: CGFloat = 12

    // State
    @Binding var selected: Int
    var initialIndex: Int = 0

    // Callbacks
    var onScrollBegin: (() -> Void)?
    var onScrollEnd: ((Int) -> Void)?
    var onTap: ((Int) -> Void)?
    var onCenteredItemChanged: ((Int) -> Void)?

    @State private var isCompact: Bool = true
    @State private var collapseTask: DispatchWorkItem? = nil

    private var dialContent: some View {
        InnerRepresentable(
            items: items,
            spacing: spacing,
            itemSize: itemSize,
            font: font,
            tintColor: tintColor,
            animationDuration: animationDuration,
            scrollEndDelay: scrollEndDelay,
            hapticsEnabled: hapticsEnabled,
            selected: $selected,
            initialIndex: initialIndex,
            onScrollBegin: {
                if compactEnabled {
                    collapseTask?.cancel()
                    withAnimation(.easeOut(duration: animationDuration)) { isCompact = false }
                }
                onScrollBegin?()
            },
            onScrollEnd: { idx in
                if compactEnabled {
                    withAnimation(.easeOut(duration: animationDuration)) { isCompact = true }
                }
                onScrollEnd?(idx)
            },
            onTap: { idx in
                if compactEnabled {
                    collapseTask?.cancel()
                    withAnimation(.easeOut(duration: animationDuration)) { isCompact = false }
                    let task = DispatchWorkItem {
                        withAnimation(.easeOut(duration: animationDuration)) { isCompact = true }
                    }
                    collapseTask = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + collapseDelayAfterTap, execute: task)
                }
                onTap?(idx)
            },
            onCenteredItemChanged: onCenteredItemChanged
        )
    }

    var body: some View {
        let base = dialContent
            .frame(width: (compactEnabled && isCompact) ? compactWidth : nil)
            .onAppear { isCompact = initialCompact }
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .white, location: 0.15),
                        .init(color: .white, location: 0.85),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

        // Replace previous experimental Button(.glass) overlay (which could appear flat/white) with
        // a consistent reusable glass surface (material + stroke + highlight) for visual parity.
        if useButtonGlassBackground {
            let effectiveRadius = min(buttonCornerRadius, max(itemSize.height / 2, 4))
            Group {
                if #available(iOS 18.0, *) {
                    base.background {
                        Button(action: {}) { Color.clear }
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.glass)
                            .allowsHitTesting(false)
                            .clipShape(Capsule())
                    }
                } else {
                    base.glassSurface(
                        cornerRadius: effectiveRadius,
                        material: .thinMaterial,
                        strokeOpacity: 0.34,
                        highlightOpacity: 0.28,
                        diagonalSheenOpacity: 0.16,
                        radialSheenOpacity: 0.13,
                        baseLuminanceOpacity: 0.12
                    )
                    .clipShape(Capsule())
                }
            }
        } else {
            base
        }
    }

    // Inner UIViewRepresentable bridge
    private struct InnerRepresentable: UIViewRepresentable {
        var items: [GlassSnapDialItem]
        var spacing: CGFloat
        var itemSize: CGSize
        var font: UIFont
        var tintColor: UIColor
        var animationDuration: TimeInterval
        var scrollEndDelay: TimeInterval
        var hapticsEnabled: Bool
        @Binding var selected: Int
        var initialIndex: Int
        var onScrollBegin: (() -> Void)?
        var onScrollEnd: ((Int) -> Void)?
        var onTap: ((Int) -> Void)?
        var onCenteredItemChanged: ((Int) -> Void)?

        func makeUIView(context: Context) -> GlassSnapDial {
            let dial = GlassSnapDial()
            dial.animationDuration = animationDuration
            dial.scrollEndDelay = scrollEndDelay
            dial.hapticsEnabled = hapticsEnabled

            dial.onCenteredItemChanged = { index in
                DispatchQueue.main.async {
                    self.selected = index
                    self.onCenteredItemChanged?(index)
                }
            }
            dial.onScrollBegin = { DispatchQueue.main.async { self.onScrollBegin?() } }
            dial.onScrollEnd = { index in DispatchQueue.main.async { self.onScrollEnd?(index) } }
            dial.onTap = { index in DispatchQueue.main.async { self.onTap?(index); self.selected = index } }

            dial.setItems(items, itemSize: itemSize, font: font, tintColor: tintColor, spacing: spacing)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dial.scrollToIndex(self.initialIndex, animated: false)
            }
            return dial
        }

        func updateUIView(_ uiView: GlassSnapDial, context: Context) {
            uiView.animationDuration = animationDuration
            uiView.scrollEndDelay = scrollEndDelay
            uiView.hapticsEnabled = hapticsEnabled
            uiView.setItems(items, itemSize: itemSize, font: font, tintColor: tintColor, spacing: spacing)
        }
    }
}

// MARK: - Preview
#Preview {
    struct Demo: View {
        @State private var selected: Int = 0
        @State private var lastEnded: Int = -1
        @State private var compact: Bool = true
        @State private var collapseTask: DispatchWorkItem? = nil

        private var items: [GlassSnapDialItem] {
            // Base (outline) icons + per-item highlight colors; highlighted uses ".fill"
            let configs: [(name: String, color: UIColor)] = [
                ("star", .systemOrange),
                ("heart", .systemPink),
                ("moon", .systemPurple),
                ("sun.max", .systemRed),
                ("cloud", .systemTeal),
            ]
            return configs.map { cfg in
                let base = UIImage(systemName: cfg.name) ?? UIImage()
                let filled = UIImage(systemName: "\(cfg.name).fill")
                let label = cfg.name
                return GlassSnapDialItem(
                    icon: base,
                    label: label,
                    highlightColor: cfg.color,
                    highlightedIcon: filled
                )
            }
        }

        var body: some View {

            let animationDuration: TimeInterval = 0.3
            
            VStack(spacing: 16) {
                GlassSnapDialView(
                    items: items,
                    spacing: 0,
                    itemSize: CGSize(width: 52, height: 56),
                    font: .systemFont(ofSize: 12, weight: .semibold),
                    tintColor: UIColor.label,
                    animationDuration: animationDuration,
                    scrollEndDelay: 1.0,
                    hapticsEnabled: false,
                    compactEnabled: true,
                    initialCompact: true,
                    compactWidth: 240,
                    collapseDelayAfterTap: 1.5,
                    useButtonGlassBackground: true,
                    selected: $selected,
                    initialIndex: 0,
                    onScrollBegin: {},
                    onScrollEnd: { idx in lastEnded = idx },
                    onTap: { _ in }
                )
                .frame(height: 64)
                .elevatedShadow()

                Text("Selected: \(selected)  •  Last Ended: \(lastEnded)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return Demo()
}
