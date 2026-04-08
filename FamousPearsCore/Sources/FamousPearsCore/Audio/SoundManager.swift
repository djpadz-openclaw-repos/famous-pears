import Foundation
import AVFoundation

@MainActor
public class SoundManager: NSObject, ObservableObject {
    public static let shared = SoundManager()
    
    @Published public var soundEnabled = true
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    public override init() {
        super.init()
        setupAudio()
    }
    
    private func setupAudio() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    public func playCorrectAnswer() {
        playSound(named: "correct", frequency: 800, duration: 0.3)
    }
    
    public func playIncorrectAnswer() {
        playSound(named: "incorrect", frequency: 400, duration: 0.5)
    }
    
    public func playRoundStart() {
        playSound(named: "roundStart", frequency: 600, duration: 0.2)
    }
    
    public func playRoundEnd() {
        playSound(named: "roundEnd", frequency: 700, duration: 0.4)
    }
    
    public func playGameStart() {
        playSound(named: "gameStart", frequency: 523, duration: 0.5)
    }
    
    public func playGameEnd() {
        playSound(named: "gameEnd", frequency: 659, duration: 0.6)
    }
    
    public func playButtonTap() {
        playSound(named: "tap", frequency: 1000, duration: 0.1)
    }
    
    private func playSound(named: String, frequency: Float, duration: TimeInterval) {
        guard soundEnabled else { return }
        
        let audioEngine = AVAudioEngine()
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(44100 * duration))!
        
        let floatArray = audioBuffer.floatChannelData![0]
        let sampleRate = Float(44100)
        let frameCount = audioBuffer.frameCapacity
        
        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / sampleRate
            let sine = sin(2.0 * .pi * frequency * time)
            let envelope = max(0, 1.0 - (time / Float(duration)))
            floatArray[frame] = sine * envelope * 0.3
        }
        
        audioBuffer.frameLength = frameCount
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(AVAudioUnitTimePitch())
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFormat)
        
        do {
            try audioEngine.start()
            audioPlayerNode.play()
            audioPlayerNode.scheduleBuffer(audioBuffer, completionHandler: nil)
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}
