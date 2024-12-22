import Combine
import SwiftUI

public class DynamicNotch<Content>: ObservableObject where Content: View {
    public var windowController: NSWindowController?

    // Content Properties
    @Published var content: () -> Content
    @Published var contentID: UUID
    @Published var isVisible: Bool = false

    // Notch Size
    @Published var notchWidth: CGFloat = 0
    @Published var notchHeight: CGFloat = 0

    // Notch Closing Properties
    @Published var isMouseInside: Bool = false
    private var timer: Timer?
    var workItem: DispatchWorkItem?
    private var subscription: AnyCancellable?

    // Notch Style
    private var notchStyle: Style = .notch
    public enum Style {
        case notch
        case floating
        case auto
    }

    private var maxAnimationDuration: Double = 0.8
    var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            Animation.spring(.bouncy(duration: 0.4))
        } else {
            Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }

    public init(contentID: UUID = .init(), style: Style = .auto, @ViewBuilder content: @escaping () -> Content) {
        self.contentID = contentID
        self.content = content
        self.notchStyle = style
        self.subscription = NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                guard let self, let screen = NSScreen.screens.first else { return }
                self.initializeWindow(screen: screen)
            }
    }
    
    public func setContent(contentID: UUID = .init(), @ViewBuilder content: @escaping () -> Content) {
        withAnimation {
            self.content = content
            self.contentID = contentID
        }
    }
    
    func initializeWindow(screen: NSScreen) {
        deinitializeWindow()
        refreshNotchSize(screen)

        let view: NSView = {
            switch notchStyle {
            case .notch: NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white))
            case .floating: NSHostingView(rootView: NotchlessView(dynamicNotch: self))
            case .auto: screen.hasNotch ? NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white)) : NSHostingView(rootView: NotchlessView(dynamicNotch: self))
            }
        }()

        let panel = DynamicNotchPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.contentView = view
        panel.orderFrontRegardless()
        panel.setFrame(screen.frame, display: false)

        windowController = .init(window: panel)
    }

    func refreshNotchSize(_ screen: NSScreen) {
        if let notchSize = screen.notchSize {
            notchWidth = notchSize.width
            notchHeight = notchSize.height
        } else {
            notchWidth = 300
            notchHeight = screen.frame.maxY - screen.visibleFrame.maxY
        }
    }

    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
    
    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        guard !isVisible else {
            if time > 0 {
                self.workItem?.cancel()
                let workItem = DispatchWorkItem { self.hide() }
                self.workItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: workItem)
            }
            return
        }
        timer?.invalidate()
        initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
            }
        }

        if time != 0 {
            self.workItem?.cancel()
            let workItem = DispatchWorkItem { self.hide() }
            self.workItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: workItem)
        }
    }

    public func hide(ignoreMouse: Bool = false) {
        guard isVisible else { return }

        if !ignoreMouse, isMouseInside {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hide()
            }
            return
        }

        withAnimation(animation) {
            self.isVisible = false
        }

        timer = Timer.scheduledTimer(withTimeInterval: maxAnimationDuration, repeats: false) { _ in
            self.deinitializeWindow()
        }
    }

    public func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
} 