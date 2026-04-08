import XCTest
@testable import FamousPeersCore

final class DuoTests: XCTestCase {
    
    var testDuo: Duo!
    
    override func setUp() {
        super.setUp()
        testDuo = Duo(
            id: 1,
            category: "music",
            duoName: "Simon & Garfunkel",
            member1: "Paul Simon",
            member1Points: 1,
            member2: "Art Garfunkel",
            member2Points: 2,
            hint: "Classic 1960s folk duo"
        )
    }
    
    func testDuoInitialization() {
        XCTAssertEqual(testDuo.id, 1)
        XCTAssertEqual(testDuo.category, "music")
        XCTAssertEqual(testDuo.duoName, "Simon & Garfunkel")
        XCTAssertEqual(testDuo.member1, "Paul Simon")
        XCTAssertEqual(testDuo.member1Points, 1)
        XCTAssertEqual(testDuo.member2, "Art Garfunkel")
        XCTAssertEqual(testDuo.member2Points, 2)
        XCTAssertEqual(testDuo.hint, "Classic 1960s folk duo")
    }
    
    func testGetRandomMember() {
        var member1Count = 0
        var member2Count = 0
        
        // Run 100 times to check randomness
        for _ in 0..<100 {
            let member = testDuo.getRandomMember()
            if member == testDuo.member1 {
                member1Count += 1
            } else if member == testDuo.member2 {
                member2Count += 1
            }
        }
        
        // Both members should be selected at least once
        XCTAssertGreater(member1Count, 0)
        XCTAssertGreater(member2Count, 0)
        
        // Should be roughly balanced (not perfect, but reasonable)
        XCTAssertGreater(member1Count, 20)
        XCTAssertGreater(member2Count, 20)
    }
    
    func testGetOtherMemberFromMember1() {
        let other = testDuo.getOtherMember(testDuo.member1)
        XCTAssertEqual(other, testDuo.member2)
    }
    
    func testGetOtherMemberFromMember2() {
        let other = testDuo.getOtherMember(testDuo.member2)
        XCTAssertEqual(other, testDuo.member1)
    }
    
    func testGetOtherMemberWithUnknownMember() {
        let other = testDuo.getOtherMember("Unknown Person")
        // Should return member2 (the default case)
        XCTAssertEqual(other, testDuo.member2)
    }
    
    func testGetPointsForMember1() {
        let points = testDuo.getPointsForMember(testDuo.member1)
        XCTAssertEqual(points, 1)
    }
    
    func testGetPointsForMember2() {
        let points = testDuo.getPointsForMember(testDuo.member2)
        XCTAssertEqual(points, 2)
    }
    
    func testGetPointsForUnknownMember() {
        let points = testDuo.getPointsForMember("Unknown Person")
        // Should return member2Points (the default case)
        XCTAssertEqual(points, testDuo.member2Points)
    }
    
    func testDuoIdentifiable() {
        XCTAssertEqual(testDuo.id, 1)
    }
    
    func testDuoCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let encoded = try encoder.encode(testDuo)
            let decoded = try decoder.decode(Duo.self, from: encoded)
            
            XCTAssertEqual(decoded.id, testDuo.id)
            XCTAssertEqual(decoded.duoName, testDuo.duoName)
            XCTAssertEqual(decoded.member1, testDuo.member1)
            XCTAssertEqual(decoded.member2, testDuo.member2)
        } catch {
            XCTFail("Encoding/decoding failed: \(error)")
        }
    }
}
