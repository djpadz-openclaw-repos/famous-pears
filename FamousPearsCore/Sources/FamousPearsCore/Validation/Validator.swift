import Foundation

public struct Validator {
    public static func checkAnswer(_ answer: String, against correctAnswer: String) -> Bool {
        let normalizedAnswer = normalize(answer)
        let normalizedCorrect = normalize(correctAnswer)
        
        // Exact match
        if normalizedAnswer == normalizedCorrect {
            return true
        }
        
        // Check if answer contains the correct answer (for multi-word names)
        if normalizedAnswer.contains(normalizedCorrect) || normalizedCorrect.contains(normalizedAnswer) {
            return true
        }
        
        // Levenshtein distance for typos (allow 1-2 character differences)
        let distance = levenshteinDistance(normalizedAnswer, normalizedCorrect)
        return distance <= 2
    }
    
    private static func normalize(_ string: String) -> String {
        string
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
    }
    
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1)
        let s2 = Array(s2)
        let m = s1.count
        let n = s2.count
        
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
