//
//  TextMatcherTest.swift
//  
//
//  Created by Thomas Moore on 8/21/22.
//

import XCTest
import PDFKit
@testable import ScanClassifier

extension TextMatcher {
    static func stub(text: String = "",
                     matchingOption: TextMatchOption? = nil,
                     clearWhiteSpace: Bool = false,
                     contentSource: PDFContentSource? = nil) -> TextMatcher {
        TextMatcher(text: text,
                    matchingOption: matchingOption,
                    clearWhiteSpace: clearWhiteSpace,
                    contentSource: contentSource)
    }
}

final class TextMatcherTest: XCTestCase {

    var testObject: TextMatcher = TextMatcher.stub()
    var mockPDFSource = MockPDFSource()

    func test_givenNoText_thenReturnMFalse() async {
        let result = await testObject.match(for: mockPDFSource, verbose: false)
        XCTAssertNil(mockPDFSource.capturedPDFContentSource)
        XCTAssertTrue(mockPDFSource.textForCalled)
        XCTAssertFalse(result)
    }

    func test_givenMatchingText_thenReturnTrue() async {
        testObject = TextMatcher.stub(text: "Doom")
        mockPDFSource.textStringToReturn = "Doom"
        let result = await testObject.match(for: mockPDFSource, verbose: false)
        XCTAssertNil(mockPDFSource.capturedPDFContentSource)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenDifferentCases_thenReturnTrue() async {
        testObject = TextMatcher.stub(text: "doom")
        mockPDFSource.textStringToReturn = "DOOM"
        let result = await testObject.match(for: mockPDFSource, verbose: false)
        XCTAssertNil(mockPDFSource.capturedPDFContentSource)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenWhitespaceIssue_DontHandleWhitespace_thenReturnFalse() async {
        testObject = TextMatcher.stub(text: "doomindream")
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource, verbose: false)
        XCTAssertNil(mockPDFSource.capturedPDFContentSource)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertFalse(result)
    }

    func test_givenMatchingText_givenWhitespaceIssue_thenReturnTrue() async {
        testObject = TextMatcher.stub(text: "doomindream", clearWhiteSpace: true)
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource, verbose: false)
        XCTAssertNil(mockPDFSource.capturedPDFContentSource)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenRect_thenReturnTrue() async {
        let testSource = PDFContentSource(start: 1, end: 1, rect: CGRect.zero)
        testObject = TextMatcher.stub(text: "doom in dream", contentSource: testSource)
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource, verbose: false)
        XCTAssertEqual(testSource.rect, mockPDFSource.capturedPDFContentSource?.rect ?? CGRect(x: 10, y: 10, width: 10, height: 10))
        XCTAssertEqual(testSource.start, mockPDFSource.capturedPDFContentSource?.start ?? -1)
        XCTAssertEqual(testSource.end, mockPDFSource.capturedPDFContentSource?.end ?? -1)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenRange_thenReturnTrue() async {
        let testSource = PDFContentSource(start: 0, end: 1, rect: nil)
        testObject = TextMatcher.stub(text: "doom in dream", contentSource: testSource)
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource, verbose: false)
        XCTAssertEqual(testSource.start, mockPDFSource.capturedPDFContentSource?.start ?? -1)
        XCTAssertEqual(testSource.end, mockPDFSource.capturedPDFContentSource?.end ?? -1)
        XCTAssertNil(mockPDFSource.capturedPDFContentSource?.rect)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

}
