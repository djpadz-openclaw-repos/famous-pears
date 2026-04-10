import AVFoundation
import UIKit

public class SoundManager {
    public static let shared = SoundManager()
    
    public var soundEnabled = true
    public var hapticsEnabled = true
    
    private init() {}
    
    public func playCorrectSound() {
        if soundEnabled {
            AudioServicesPlaySystemSound(1057) // Positive feedback sound
        }
        if hapticsEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }
    
    public func playIncorrectSound() {
        if soundEnabled {
            AudioServicesPlaySystemSound(1053) // Negative feedback sound
        }
        if hapticsEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
        }
    }
    
    public func playRoundStartSound() {
        if soundEnabled {
            AudioServicesPlaySystemSound(1104) // Notification sound
        }
        if hapticsEnabled {
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }
    }
    
    public func playGameEndSound() {
        if soundEnabled {
            AudioServicesPlaySystemSound(1057) // Success sound
        }
        if hapticsEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }
    
    public func playTapSound() {
        if soundEnabled {
            AudioServicesPlaySystemSound(1104)
        }
        if hapticsEnabled {
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }
    }
}
