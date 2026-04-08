import AVFoundation
import UIKit

public class SoundManager {
    public static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private let soundQueue = DispatchQueue(label: "com.famousPears.sound")
    
    public var isSoundEnabled = true
    public var isHapticsEnabled = true
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    public func playCorrectSound() {
        guard isSoundEnabled else { return }
        playSystemSound(1057) // "Ding" sound
        triggerHaptic(.success)
    }
    
    public func playIncorrectSound() {
        guard isSoundEnabled else { return }
        playSystemSound(1053) // "Buzzer" sound
        triggerHaptic(.error)
    }
    
    public func playRoundStartSound() {
        guard isSoundEnabled else { return }
        playSystemSound(1104) // "Chime" sound
        triggerHaptic(.light)
    }
    
    public func playGameEndSound() {
        guard isSoundEnabled else { return }
        playSystemSound(1111) // "Fanfare" sound
        triggerHaptic(.success)
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        soundQueue.async {
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    public func triggerImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
