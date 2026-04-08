import SwiftUI

public struct AnimationConstants {
    public static let shortDuration: Double = 0.3
    public static let mediumDuration: Double = 0.5
    public static let longDuration: Double = 0.8
    
    public static let easeInOut = Animation.easeInOut(duration: mediumDuration)
    public static let spring = Animation.spring(response: 0.6, dampingFraction: 0.7)
}

public struct ScaleEffect: ViewModifier {
    let scale: CGFloat
    let opacity: Double
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

public extension View {
    func scaleWithOpacity(_ scale: CGFloat, opacity: Double = 1.0) -> some View {
        modifier(ScaleEffect(scale: scale, opacity: opacity))
    }
    
    func popIn() -> some View {
        self
            .scaleEffect(0.5)
            .opacity(0)
            .onAppear {
                withAnimation(AnimationConstants.spring) {
                    self.scaleEffect(1.0)
                    self.opacity(1.0)
                }
            }
    }
    
    func slideIn(from edge: Edge) -> some View {
        let offset: CGFloat = 50
        let x = edge == .leading ? -offset : (edge == .trailing ? offset : 0)
        let y = edge == .top ? -offset : (edge == .bottom ? offset : 0)
        
        return self
            .offset(x: x, y: y)
            .opacity(0)
            .onAppear {
                withAnimation(AnimationConstants.easeInOut) {
                    self.offset(x: 0, y: 0)
                    self.opacity(1)
                }
            }
    }
    
    func fadeIn() -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(AnimationConstants.easeInOut) {
                    self.opacity(1)
                }
            }
    }
    
    func pulse() -> some View {
        self
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    self.opacity(0.6)
                }
            }
    }
}
