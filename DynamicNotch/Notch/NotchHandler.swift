import SwiftUI
import Combine

@MainActor
final class NotchHandler: ObservableObject {
    @Published private(set) var isVisible = false
    private var notchInfo: NotchInformation<Image>?
    
    static let shared = NotchHandler()
    private init() {}
    
    func showNotification(icon: String = "bell.fill", title: String, description: String? = nil, duration: Double = 3) {
        notchInfo = NotchInformation(
            icon: Image(systemName: icon),
            title: title,
            description: description,
            iconColor: .white,
            textColor: .white
        )
        
        notchInfo?.show(duration: duration)
        isVisible = true
        
        if duration > 0 {
            Task {
                try? await Task.sleep(for: .seconds(duration))
                if !Task.isCancelled {
                     hideNotification()
                }
            }
        }
    }
    
    func hideNotification() {
        notchInfo?.hide()
        isVisible = false
    }
    
    func updateNotification(icon: String, title: String, description: String?) {
        Task { @MainActor in
            notchInfo?.update(
                icon: Image(systemName: icon),
                title: title,
                description: description
            )
        }
    }
}
