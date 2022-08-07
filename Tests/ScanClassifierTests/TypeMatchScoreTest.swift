//
//  TypeMatchScoreTest.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import XCTest
import ScanClassifier

class TypeMatchScoreTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    // MARK: - isMatched
    func test_isMatched_given_allFail_thenFalse() {
        let matchTypes: [MatchType] = [.failed,
                                       .failed,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isMatched)
    }

    func test_isMatched_given_allMatchTypes_thenFalse() {
        let matchTypes: [MatchType] = [.match,
                                       .failed,
                                       .optionalMatch,
                                       .optionalFailed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isMatched)
    }

    func test_isMatched_given_allMatchTypesExceptFail_thenTrue() {
        let matchTypes: [MatchType] = [.match,
                                       .optionalMatch,
                                       .optionalFailed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertTrue(testObject.isMatched)
    }

    func test_isMatched_given_allMatchTypesExceptFailDifferentOrder_thenTrue() {
        let matchTypes: [MatchType] = [.optionalMatch,
                                       .optionalFailed,
                                       .match]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertTrue(testObject.isMatched)
    }

    func test_isMatched_given_noMatchOrFail_thenFalse() {
        let matchTypes: [MatchType] = [.optionalMatch,
                                       .optionalFailed
        ]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isMatched)
    }

    // MARK: - isStrong

    func test_isStrong_given_allFail_thenFalse() {
        let matchTypes: [MatchType] = [.failed,
                                       .failed,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isStrong)
    }

    func test_isStrong_given_allMatchTypes_thenFalse() {
        let matchTypes: [MatchType] = [.match,
                                       .failed,
                                       .optionalMatch,
                                       .optionalFailed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isStrong)
    }

    func test_isStrong_given_allMatchTypesExceptFail_thenTrue() {
        let matchTypes: [MatchType] = [.match,
                                       .optionalMatch,
                                       .optionalFailed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertTrue(testObject.isStrong)
    }

    func test_isStrong_given_allMatchTypesExceptFailDifferentOrder_thenTrue() {
        let matchTypes: [MatchType] = [.optionalMatch,
                                       .optionalFailed,
                                       .match]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertTrue(testObject.isStrong)
    }


    func test_isStrong_given_allMatchTypesExceptFailOptionalMatch_thenFalse() {
        let matchTypes: [MatchType] = [.match,
                                       .optionalFailed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isStrong)
    }

    // MARK: - isWeak

    func test_isWeak_given_allFail_thenFalse() {
        let matchTypes: [MatchType] = [.failed,
                                       .failed,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isWeak)
    }

    func test_isWeak_given_allMatchTypes_thenTrue() {
        let matchTypes: [MatchType] = [.match,
                                       .failed,
                                       .optionalMatch,
                                       .optionalFailed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertTrue(testObject.isWeak)
    }

    func test_isWeak_given_allMatchTypesExceptFail_thenFalse() {
        let matchTypes: [MatchType] = [.match,
                                       .optionalMatch,
                                       .optionalFailed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isWeak)
    }

    func test_isWeak_given_allMatchTypesExceptFailDifferentOrder_thenFalse() {
        let matchTypes: [MatchType] = [.optionalMatch,
                                       .optionalFailed,
                                       .match]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isWeak)
    }

    func test_isWeak_given_noMatchButOptionalMatch_thenTrue() {
        let matchTypes: [MatchType] = [.optionalMatch,
                                       .optionalFailed,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertTrue(testObject.isWeak)
    }

    func test_isWeak_given_noMatchNoOptionalMatch_thenFalse() {
        let matchTypes: [MatchType] = [.optionalFailed,
                                       .optionalFailed,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertFalse(testObject.isWeak)
    }

    // MARK: - MatchScore

    func test_matchScore_givenAllTypes_thenReturnWeak() {
        let matchTypes: [MatchType] = [.match,
                                       .optionalFailed,
                                       .optionalFailed,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertEqual(testObject.matchScore, .weak)
    }

    func test_matchScore_givenNoMatches_thenReturnFail() {
        let matchTypes: [MatchType] = [.optionalFailed,
                                       .optionalFailed,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertEqual(testObject.matchScore, .fail)
    }

    func test_matchScore_givenOptionalMatch_thenReturnWeak() {
        let matchTypes: [MatchType] = [.optionalFailed,
                                       .optionalFailed,
                                       .optionalMatch,
                                       .failed]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertEqual(testObject.matchScore, .weak)
    }

    func test_matchScore_givenMutlipleMatch_thenReturnStrong() {
        let matchTypes: [MatchType] = [
                                       .optionalMatch,
                                       .match]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertEqual(testObject.matchScore, .strong)
    }

    func test_matchScore_givenSingleMatch_thenReturnStrong() {
        let matchTypes: [MatchType] = [
                                       .optionalFailed,
                                       .match]
        let testObject = TypeMatchScore(results: matchTypes)
        XCTAssertEqual(testObject.matchScore, .match)
    }

}
