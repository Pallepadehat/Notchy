import SwiftUI
import AppKit

@MainActor
final class NotchController: NSObject, ObservableObject {
    @Published private(set) var isVisible = false
    private var hostingView: NSHostingView<AnyView>?
    private lazy var window: NotchWindow = {
        let window = NotchWindow()
        window.delegate = self
        return window
    }()
    
    static let shared = NotchController()
    private override init() {
        super.init()
        setupWindow()
    }
    
    private func setupWindow() {
        window.setFrame(NSRect(
            x: 0, y: 0,
            width: NotchManager.getPhysicalNotchWidth(),
            height: NotchManager.getPhysicalNotchHeight()
        ), display: false)
        
        if let screen = NSScreen.main {
            let x = screen.frame.midX - window.frame.width / 2
            let y = screen.frame.maxY - window.frame.height
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
    
    func show<Content: View>(@ViewBuilder content: () -> Content) {
        let view = content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        if hostingView == nil {
            hostingView = NSHostingView(rootView: AnyView(view))
            window.contentView = hostingView
        } else {
            withAnimation(.smooth) {
                hostingView?.rootView = AnyView(view)
            }
        }
        
        if !window.isVisible {
            window.orderFront(nil)
            withAnimation(.smooth) {
                isVisible = true
            }
        }
    }
    
    func hide() {
        withAnimation(.smooth) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.window.orderOut(nil)
        }
    }
    
    func toggle<Content: View>(@ViewBuilder content: () -> Content) {
        if isVisible {
            hide()
        } else {
            show(content: content)
        }
    }
}

extension NotchController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        isVisible = false
    }
} 