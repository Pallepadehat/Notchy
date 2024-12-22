import SwiftUI

@MainActor
final class CustomInfoHandler: ObservableObject {
    @Published private(set) var isVisible = false
    @Published private(set) var isHovered = false
    private let notchInfo: NotchInformation<Image>
    
    static let shared = CustomInfoHandler()
    
    private init() {
        self.notchInfo = NotchInformation(
            icon: Image(systemName: "person.fill"),
            title: "Human Human Human Human",
            description: "With a description!",
            iconColor: .white,
            textColor: .white
        )
    }
    
    func show() {
        withAnimation(.smooth) {
            isVisible = true
            notchInfo.show()
        }
    }
    
    func hide() {
        withAnimation(.smooth) {
            isVisible = false
            notchInfo.hide()
        }
    }
    
    func toggle() {
        withAnimation(.smooth) {
            if isVisible {
                hide()
            } else {
                show()
            }
        }
    }
    
    func updateContent(icon: String, title: String, description: String?) {
        Task { @MainActor in
            notchInfo.update(
                icon: Image(systemName: icon),
                title: title,
                description: description
            )
        }
    }
    
    func setHovered(_ value: Bool) {
        withAnimation(.smooth) {
            isHovered = value
        }
    }
} 