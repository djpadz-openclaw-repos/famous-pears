import SwiftUI

public struct AnimationModifiers {
    public static func popIn() -> some ViewModifier {
        PopInModifier()
    }
    
    public static func slideIn(from edge: Edge = .leading) -> some ViewModifier {
        SlideInModifier(edge: edge)
    }
    
    public static func fadeIn() -> some ViewModifier {
        FadeInModifier()
    }
    
    public static func pulse() -> some ViewModifier {
        PulseModifier()
    }
}

private struct PopInModifier: ViewModifier {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

private struct SlideInModifier: ViewModifier {
    let edge: Edge
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var initialOffset: CGFloat {
        switch edge {
        case .leading: return -100
        case .trailing: return 100
        case .top: return -100
        case .bottom: return 100
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: edge == .leading || edge == .trailing ? offset : 0,
                   y: edge == .top || edge == .bottom ? offset : 0)
            .opacity(opacity)
            .onAppear {
                offset = initialOffset
                opacity = 0
                withAnimation(.easeInOut(duration: 0.5)) {
                    offset = 0
                    opacity = 1.0
                }
            }
    }
}

private struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 1.0
                }
            }
    }
}

private struct PulseModifier: ViewModifier {
    @State private var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 0.5
                }
            }
    }
}

public extension View {
    func popIn() -> some View {
        modifier(PopInModifier())
    }
    
    func slideIn(from edge: Edge = .leading) -> some View {
        modifier(SlideInModifier(edge: edge))
    }
    
    func fadeIn() -> some View {
        modifier(FadeInModifier())
    }
    
    func pulse() -> some View {
        modifier(PulseModifier())
    }
}
