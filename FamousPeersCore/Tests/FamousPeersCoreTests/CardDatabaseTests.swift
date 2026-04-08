import XCTest
@testable import FamousPeersCore

final class CardDatabaseTests: XCTestCase {
    
    func testCardDatabaseLoads() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        XCTAssertGreater(allCards.count, 0)
    }
    
    func testCardStructure() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        
        for card in allCards {
            XCTAssertGreater(card.id, 0)
            XCTAssertFalse(card.duoName.isEmpty)
            XCTAssertFalse(card.member1.isEmpty)
            XCTAssertFalse(card.member2.isEmpty)
            XCTAssertGreater(card.member1Points, 0)
            XCTAssertGreater(card.member2Points, 0)
            XCTAssertFalse(card.category.isEmpty)
        }
    }
    
    func testGetCardById() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        
        guard let firstCard = allCards.first else {
            XCTFail("No cards in database")
            return
        }
        
        let retrievedCard = db.getCard(id: firstCard.id)
        XCTAssertNotNil(retrievedCard)
        XCTAssertEqual(retrievedCard?.id, firstCard.id)
        XCTAssertEqual(retrievedCard?.duoName, firstCard.duoName)
    }
    
    func testGetNonexistentCard() {
        let db = CardDatabase.shared
        let card = db.getCard(id: 99999)
        XCTAssertNil(card)
    }
    
    func testGetRandomCard() {
        let db = CardDatabase.shared
        let card1 = db.getRandomCard()
        let card2 = db.getRandomCard()
        
        XCTAssertNotNil(card1)
        XCTAssertNotNil(card2)
        // Cards might be the same, but both should be valid
        XCTAssertGreater(card1?.id ?? 0, 0)
        XCTAssertGreater(card2?.id ?? 0, 0)
    }
    
    func testGetCardsByDifficulty() {
        let db = CardDatabase.shared
        
        // Test easy cards (1-2 points)
        let easyCards = db.getAllCards().filter { $0.member1Points <= 2 && $0.member2Points <= 2 }
        XCTAssertGreater(easyCards.count, 0)
        
        // Test hard cards (3-5 points)
        let hardCards = db.getAllCards().filter { $0.member1Points >= 3 || $0.member2Points >= 3 }
        XCTAssertGreater(hardCards.count, 0)
    }
    
    func testCardPointValues() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        
        for card in allCards {
            // Points should be between 1 and 5
            XCTAssertGreaterThanOrEqual(card.member1Points, 1)
            XCTAssertLessThanOrEqual(card.member1Points, 5)
            XCTAssertGreaterThanOrEqual(card.member2Points, 1)
            XCTAssertLessThanOrEqual(card.member2Points, 5)
        }
    }
    
    func testCardCategories() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        
        let categories = Set(allCards.map { $0.category })
        XCTAssertGreater(categories.count, 0)
        
        // Should have multiple categories
        let expectedCategories = ["music", "movies", "tech", "history", "concepts"]
        for category in expectedCategories {
            let hasCategory = allCards.contains { $0.category == category }
            XCTAssertTrue(hasCategory, "Missing category: \(category)")
        }
    }
    
    func testDuoMembersAreUnique() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        
        for card in allCards {
            // Members should be different (except for conceptual pairs)
            if card.category != "concepts" {
                XCTAssertNotEqual(card.member1.lowercased(), card.member2.lowercased())
            }
        }
    }
    
    func testCardHints() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        
        for card in allCards {
            XCTAssertFalse(card.hint.isEmpty, "Card \(card.id) has empty hint")
        }
    }
    
    func testNoDuplicateCardIds() {
        let db = CardDatabase.shared
        let allCards = db.getAllCards()
        
        let ids = allCards.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count, "Duplicate card IDs found")
    }
    
    func testCardDatabaseConsistency() {
        let db = CardDatabase.shared
        let allCards1 = db.getAllCards()
        let allCards2 = db.getAllCards()
        
        XCTAssertEqual(allCards1.count, allCards2.count)
        
        for (card1, card2) in zip(allCards1, allCards2) {
            XCTAssertEqual(card1.id, card2.id)
            XCTAssertEqual(card1.duoName, card2.duoName)
        }
    }
}
