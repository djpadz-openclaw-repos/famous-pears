import Foundation

public class Validator {
    public static func validateAnswer(_ answer: String, against correctAnswer: String) -> Bool {
        let normalizedAnswer = answer.lowercased().trimmingCharacters(in: .whitespaces)
        let normalizedCorrect = correctAnswer.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Exact match
        if normalizedAnswer == normalizedCorrect {
            return true
        }
        
        // Partial match (first or last name)
        let answerWords = normalizedAnswer.split(separator: " ").map(String.init)
        let correctWords = normalizedCorrect.split(separator: " ").map(String.init)
        
        for correctWord in correctWords {
            for answerWord in answerWords {
                if correctWord == answerWord {
                    return true
                }
            }
        }
        
        // Fuzzy match with Levenshtein distance (allow 1-2 character differences)
        if levenshteinDistance(normalizedAnswer, normalizedCorrect) <= 2 {
            return true
        }
        
        return false
    }
    
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1)
        let s2 = Array(s2)
        let m = s1.count
        let n = s2.count
        
        // Handle empty strings
        if m == 0 { return n }
        if n == 0 { return m }
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            dp[i][0] = i
        }
        for j in 0...n {
            dp[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                if s1[i - 1] == s2[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = 1 + min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
                }
            }
        }
        
        return dp[m][n]
    }
}
