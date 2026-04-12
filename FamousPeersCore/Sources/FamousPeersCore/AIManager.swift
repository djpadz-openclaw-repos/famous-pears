import Foundation

public class AIManager {
    public enum Difficulty {
        case easy
        case medium
        case hard
    }
    
    private let difficulty: Difficulty
    
    public init(difficulty: Difficulty = .medium) {
        self.difficulty = difficulty
    }
    
    // Generate a clue based on the duo member
    public func generateClue(for member: String, hint: String) -> String {
        switch difficulty {
        case .easy:
            return generateEasyClue(member, hint)
        case .medium:
            return generateMediumClue(member, hint)
        case .hard:
            return generateHardClue(member, hint)
        }
    }
    
    // Make a guess based on the clue
    public func makeGuess(givenClue: String, possibleAnswers: [String]) -> String {
        switch difficulty {
        case .easy:
            return possibleAnswers.randomElement() ?? ""
        case .medium:
            return makeMediumGuess(givenClue, possibleAnswers)
        case .hard:
            return makeHardGuess(givenClue, possibleAnswers)
        }
    }
    
    // MARK: - Easy Difficulty
    
    private func generateEasyClue(_ member: String, _ hint: String) -> String {
        // Easy: just return the hint or a simple description
        return hint.isEmpty ? member : hint
    }
    
    // MARK: - Medium Difficulty
    
    private func generateMediumClue(_ member: String, _ hint: String) -> String {
        // Medium: combine hint with partial member info
        let words = member.split(separator: " ").map(String.init)
        if words.count > 1 {
            return "\(words[0])... (\(hint))"
        }
        return hint
    }
    
    private func makeMediumGuess(_ clue: String, _ possibleAnswers: [String]) -> String {
        // Medium: try to match based on clue keywords
        let clueWords = clue.lowercased().split(separator: " ").map(String.init)
        
        for answer in possibleAnswers {
            let answerWords = answer.lowercased().split(separator: " ").map(String.init)
            let matches = answerWords.filter { word in
                clueWords.contains { clueWord in
                    word.hasPrefix(clueWord) || clueWord.hasPrefix(word)
                }
            }
            if !matches.isEmpty {
                return answer
            }
        }
        
        return possibleAnswers.randomElement() ?? ""
    }
    
    // MARK: - Hard Difficulty
    
    private func generateHardClue(_ member: String, _ hint: String) -> String {
        // Hard: provide a detailed, specific clue
        let words = member.split(separator: " ").map(String.init)
        var clue = hint
        
        if words.count > 1 {
            clue += " First name starts with '\(words[0].prefix(1))'"
        }
        
        return clue
    }
    
    private func makeHardGuess(_ clue: String, _ possibleAnswers: [String]) -> String {
        // Hard: use sophisticated matching
        let clueWords = clue.lowercased().split(separator: " ").map(String.init)
        
        var bestMatch: (answer: String, score: Int) = ("", 0)
        
        for answer in possibleAnswers {
            let answerWords = answer.lowercased().split(separator: " ").map(String.init)
            var score = 0
            
            // Check for word matches
            for answerWord in answerWords {
                for clueWord in clueWords {
                    if answerWord.contains(clueWord) || clueWord.contains(answerWord) {
                        score += 2
                    }
                    if answerWord.hasPrefix(clueWord) {
                        score += 3
                    }
                }
            }
            
            // Check for length similarity
            if abs(answer.count - clue.count) < 10 {
                score += 1
            }
            
            if score > bestMatch.score {
                bestMatch = (answer, score)
            }
        }
        
        return bestMatch.score > 0 ? bestMatch.answer : (possibleAnswers.randomElement() ?? "")
    }
}
