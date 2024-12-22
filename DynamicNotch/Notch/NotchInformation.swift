import SwiftUI

@MainActor
final class NotchInformationPublisher<IconView: View>: ObservableObject {
    @Published var iconView: IconView?
    @Published var iconColor: Color
    @Published var title: String
    @Published var description: String?
    @Published var textColor: Color
    
    init(icon: Image?, iconColor: Color, title: String, description: String? = nil, textColor: Color) where IconView == Image {
        self.iconView = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.textColor = textColor
    }
    
    init(title: String, description: String? = nil, textColor: Color, iconView: (() -> IconView)?) {
        self.title = title
        self.description = description
        self.textColor = textColor
        self.iconColor = .clear
        self.iconView = iconView?()
    }
    
    func update(icon: IconView?, title: String, description: String?) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.iconView = icon
            self.title = title
            self.description = description
        }
    }
}

struct NotchInformationView<IconView: View>: View {
    @ObservedObject private var publisher: NotchInformationPublisher<IconView>
    
    init(publisher: NotchInformationPublisher<IconView>) {
        self.publisher = publisher
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon
            if let image = publisher.iconView as? Image {
                image
                    .resizable()
                    .foregroundStyle(publisher.iconColor)
                    .padding(3)
                    .scaledToFit()
                    .transition(.opacity.combined(with: .scale))
            } else if let iconView = publisher.iconView {
                iconView
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: publisher.description != nil ? 2 : 0) {
                Text(publisher.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(publisher.textColor)
                
                if let description = publisher.description {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(publisher.textColor.opacity(0.8))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .transition(.opacity.combined(with: .move(edge: .leading)))
            
            Spacer(minLength: 0)
        }
        .frame(height: 32)
        .padding(.horizontal, 8)
    }
}

@MainActor
final class NotchInformation<IconView: View> {
    private let notchController = NotchController.shared
    private let publisher: NotchInformationPublisher<IconView>
    private let id: UUID
    
    init(id: UUID = UUID(), icon: Image? = nil, title: String, description: String? = nil, iconColor: Color = .white, textColor: Color = .white) where IconView == Image {
        self.id = id
        self.publisher = NotchInformationPublisher(icon: icon, iconColor: iconColor, title: title, description: description, textColor: textColor)
    }
    
    init(id: UUID = UUID(), title: String, description: String? = nil, textColor: Color = .white, iconView: (() -> IconView)? = nil) {
        self.id = id
        self.publisher = NotchInformationPublisher(title: title, description: description, textColor: textColor, iconView: iconView)
    }
    
    func show(duration: Double = 0) {
        notchController.show {
            NotchInformationView(publisher: publisher)
                .id(id)
        }
        
        if duration > 0 {
            Task {
                try? await Task.sleep(for: .seconds(duration))
                if !Task.isCancelled {
                    hide()
                }
            }
        }
    }
    
    func hide() {
        notchController.hide()
    }
    
    func toggle() {
        notchController.toggle {
            NotchInformationView(publisher: publisher)
                .id(id)
        }
    }
    
    func update(icon: IconView?, title: String, description: String?) {
        publisher.update(icon: icon, title: title, description: description)
    }
} 
