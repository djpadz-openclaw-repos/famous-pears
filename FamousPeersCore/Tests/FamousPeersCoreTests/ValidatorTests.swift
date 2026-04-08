import XCTest
@testable import FamousPeersCore

final class ValidatorTests: XCTestCase {
    
    // MARK: - Exact Match Tests
    
    func testExactMatch() {
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art Garfunkel"))
    }
    
    func testExactMatchCaseInsensitive() {
        XCTAssertTrue(Validator.checkAnswer("art garfunkel", against: "Art Garfunkel"))
        XCTAssertTrue(Validator.checkAnswer("ART GARFUNKEL", against: "Art Garfunkel"))
    }
    
    func testExactMatchWithWhitespace() {
        XCTAssertTrue(Validator.checkAnswer("  Art Garfunkel  ", against: "Art Garfunkel"))
    }
    
    // MARK: - Partial Match Tests
    
    func testPartialMatchFirstName() {
        XCTAssertTrue(Validator.checkAnswer("Art", against: "Art Garfunkel"))
    }
    
    func testPartialMatchLastName() {
        XCTAssertTrue(Validator.checkAnswer("Garfunkel", against: "Art Garfunkel"))
    }
    
    func testPartialMatchContained() {
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art"))
    }
    
    // MARK: - Typo Tolerance Tests (Levenshtein Distance)
    
    func testOneCharacterTypo() {
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art Garfunkal"))
    }
    
    func testTwoCharacterTypo() {
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art Garfunkal"))
    }
    
    func testThreeCharacterTypo() {
        XCTAssertFalse(Validator.checkAnswer("Art Garfunkel", against: "Art Garfunkal"))
    }
    
    func testMissingCharacter() {
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art Garfunke"))
    }
    
    func testExtraCharacter() {
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art Garfunkell"))
    }
    
    // MARK: - Punctuation Tests
    
    func testPunctuationIgnored() {
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art Garfunkel!"))
        XCTAssertTrue(Validator.checkAnswer("Art Garfunkel", against: "Art, Garfunkel"))
    }
    
    // MARK: - Negative Tests
    
    func testCompletelyDifferentName() {
        XCTAssertFalse(Validator.checkAnswer("Paul Simon", against: "Art Garfunkel"))
    }
    
    func testEmptyAnswer() {
        XCTAssertFalse(Validator.checkAnswer("", against: "Art Garfunkel"))
    }
    
    func testEmptyCorrectAnswer() {
        XCTAssertFalse(Validator.checkAnswer("Art Garfunkel", against: ""))
    }
    
    func testBothEmpty() {
        XCTAssertTrue(Validator.checkAnswer("", against: ""))
    }
    
    // MARK: - Single Name Tests
    
    func testSingleNameExact() {
        XCTAssertTrue(Validator.checkAnswer("Paul", against: "Paul"))
    }
    
    func testSingleNamePartial() {
        XCTAssertTrue(Validator.checkAnswer("Paul", against: "Paul Simon"))
    }
    
    // MARK: - Special Characters
    
    func testApostropheHandled() {
        XCTAssertTrue(Validator.checkAnswer("O'Neill", against: "O'Neill"))
    }
    
    func testHyphenHandled() {
        XCTAssertTrue(Validator.checkAnswer("Mary-Jane", against: "Mary-Jane"))
    }
}
