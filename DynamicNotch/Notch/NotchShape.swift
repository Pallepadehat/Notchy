import SwiftUI

struct NotchShape: Shape {
    var topCornerRadius: CGFloat {
        bottomCornerRadius - 5
    }
    
    var bottomCornerRadius: CGFloat
    
    init(cornerRadius: CGFloat? = nil) {
        self.bottomCornerRadius = cornerRadius ?? 11
    }
    
    var animatableData: CGFloat {
        get { bottomCornerRadius }
        set { bottomCornerRadius = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Left top corner
        path.addArc(
            center: CGPoint(x: rect.minX, y: topCornerRadius),
            radius: topCornerRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Left bottom curve
        path.addLine(to: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY - bottomCornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + topCornerRadius + bottomCornerRadius, y: rect.maxY - bottomCornerRadius),
            radius: bottomCornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )
        
        // Bottom line
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius - bottomCornerRadius, y: rect.maxY))
        
        // Right bottom curve
        path.addArc(
            center: CGPoint(x: rect.maxX - topCornerRadius - bottomCornerRadius, y: rect.maxY - bottomCornerRadius),
            radius: bottomCornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )
        
        // Right line
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY + bottomCornerRadius))
        
        // Right top corner
        path.addArc(
            center: CGPoint(x: rect.maxX, y: topCornerRadius),
            radius: topCornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        // Top line
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
} 