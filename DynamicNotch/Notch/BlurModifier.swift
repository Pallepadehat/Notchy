import SwiftUI

private struct BlurModifier: ViewModifier {
    public let isIdentity: Bool
    public var intensity: CGFloat

    public func body(content: Content) -> some View {
        content
            .blur(radius: isIdentity ? intensity : 0)
            .opacity(isIdentity ? 0 : 1)
    }
}

extension AnyTransition {
    static var blur: AnyTransition {
        .modifier(
            active: BlurModifier(isIdentity: true, intensity: 5),
            identity: BlurModifier(isIdentity: false, intensity: 5)
        )
    }
} 