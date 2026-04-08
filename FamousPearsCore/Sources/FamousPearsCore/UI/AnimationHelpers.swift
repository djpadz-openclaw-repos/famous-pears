import SwiftUI

public struct AnimationHelpers {
    public static func scaleIn() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
    }
    
    public static func fadeIn() -> Animation {
        .easeIn(duration: 0.3)
    }
    
    public static func slideIn() -> Animation {
        .easeOut(duration: 0.4)
    }
    
    public static func pulse() -> Animation {
        .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
    }
    
    public static func bounce() -> Animation {
        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

public struct PulseModifier: ViewModifier {
    @State private var isAnimating = false
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

public struct SlideInModifier: ViewModifier {
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    
    public func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}

public struct ScaleInModifier: ViewModifier {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

public struct FlipModifier: ViewModifier {
    @State private var rotation: Double = 0
    
    public func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotation = 360
                }
            }
    }
}

extension View {
    public func pulseAnimation() -> some View {
        modifier(PulseModifier())
    }
    
    public func slideInAnimation() -> some View {
        modifier(SlideInModifier())
    }
    
    public func scaleInAnimation() -> some View {
        modifier(ScaleInModifier())
    }
    
    public func flipAnimation() -> some View {
        modifier(FlipModifier())
    }
}
