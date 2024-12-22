import SwiftUI
import AppKit

@MainActor
class NotchManager: ObservableObject {
    @Published private(set) var hasPhysicalNotch: Bool
    @Published private(set) var notchHeight: CGFloat
    @Published private(set) var notchWidth: CGFloat
    
    init() {
        // First initialize the notch detection
        let hasNotch = NotchManager.detectPhysicalNotch()
        self.hasPhysicalNotch = hasNotch
        
        // Then use the detection result to set dimensions
        if hasNotch {
            self.notchHeight = NotchManager.getPhysicalNotchHeight()
            self.notchWidth = NotchManager.getPhysicalNotchWidth()
        } else {
            self.notchHeight = 32  // Default height for virtual notch
            self.notchWidth = 180  // Default width for virtual notch
        }
    }
    
    static func detectPhysicalNotch() -> Bool {
        if let screen = NSScreen.main {
            // Check if the screen has a top safe area inset
            let frame = screen.frame
            let visibleFrame = screen.visibleFrame
            
            // If there's a significant difference between frame and visibleFrame at the top,
            // it likely indicates a notch
            return frame.height - visibleFrame.height - (visibleFrame.minY - frame.minY) > 20
        }
        return false
    }
    
    static func getPhysicalNotchHeight() -> CGFloat {
        if let screen = NSScreen.main {
            let frame = screen.frame
            let visibleFrame = screen.visibleFrame
            return frame.height - visibleFrame.height - (visibleFrame.minY - frame.minY)
        }
        return 32 // Default height if we can't detect
    }
    
    static func getPhysicalNotchWidth() -> CGFloat {
        // The physical notch width is typically around 180 points
        return 180
    }
    
    func updateNotchDimensions(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width {
            self.notchWidth = width
        }
        if let height = height {
            self.notchHeight = height
        }
    }
} 