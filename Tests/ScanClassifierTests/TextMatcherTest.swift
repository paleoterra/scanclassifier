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
                     contentRect: PDFContentRect? = nil,
                     contentRange: PDFContentPageRange? = nil) -> TextMatcher {
        TextMatcher(text: text,
                    matchingOption: matchingOption,
                    clearWhiteSpace: clearWhiteSpace,
                    contentRect: contentRect,
                    contentRange: contentRange)
    }
}

final class TextMatcherTest: XCTestCase {

    var testObject: TextMatcher = TextMatcher.stub()
    var mockPDFSource = MockPDFSource()

    func test_givenNoText_thenReturnMFalse() async {
        let result = await testObject.match(for: mockPDFSource)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRect)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRange)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertFalse(result)
    }

    func test_givenMatchingText_thenReturnTrue() async {
        testObject = TextMatcher.stub(text: "Doom")
        mockPDFSource.textStringToReturn = "Doom"
        let result = await testObject.match(for: mockPDFSource)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRect)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRange)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenDifferentCases_thenReturnTrue() async {
        testObject = TextMatcher.stub(text: "doom")
        mockPDFSource.textStringToReturn = "DOOM"
        let result = await testObject.match(for: mockPDFSource)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRect)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRange)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenWhitespaceIssue_DontHandleWhitespace_thenReturnFalse() async {
        testObject = TextMatcher.stub(text: "doomindream")
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRect)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRange)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertFalse(result)
    }

    func test_givenMatchingText_givenWhitespaceIssue_thenReturnTrue() async {
        testObject = TextMatcher.stub(text: "doomindream", clearWhiteSpace: true)
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRect)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRange)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenRect_thenReturnTrue() async {
        let testRect = PDFContentRect(rect: CGRect.zero, page: 1)
        testObject = TextMatcher.stub(text: "doom in dream", contentRect: testRect)
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource)
        XCTAssertEqual(testRect.rect, mockPDFSource.capturedPDFContentSourceRect?.rect ?? CGRect(x: 10, y: 10, width: 10, height: 10))
        XCTAssertEqual(testRect.page, mockPDFSource.capturedPDFContentSourceRect?.page ?? -1)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRange)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

    func test_givenMatchingText_givenRange_thenReturnTrue() async {
        let testRange = PDFContentPageRange(start: 0, end: 1)
        testObject = TextMatcher.stub(text: "doom in dream", contentRange: testRange)
        mockPDFSource.textStringToReturn = "DOOM in dream"
        let result = await testObject.match(for: mockPDFSource)
        XCTAssertEqual(testRange.start, mockPDFSource.capturedPDFContentSourceRange?.start ?? -1)
        XCTAssertEqual(testRange.end, mockPDFSource.capturedPDFContentSourceRange?.end ?? -1)
        XCTAssertNil(mockPDFSource.capturedPDFContentSourceRect)
        XCTAssertTrue(mockPDFSource.textForCalled)

        XCTAssertTrue(result)
    }

}
