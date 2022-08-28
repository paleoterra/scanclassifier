//
//  PDFSourceTest.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import XCTest
import Foundation
import ScanClassifier
import PDFKit

class PDFSourceTest: XCTestCase {
    var testObject: PDFSource?

    let fullContent = " Page 1 Top Left Text Box Dreamy dream of dreams\nPage 1 Top Right Text Box Catty cats from Cartland\nPage 1 Bottom left text box Rocky rocks in my rocks\nPage 1 Bottom right text box Sing sing sing\n \n Page 2 Top Left Text Box Dreamy dream of dreams\nPage 2 Top Right Text Box Catty cats from Cartland\nPage 2 Bottom left text box Rocky rocks in my rocks\nPage 2 Bottom right text box Sing sing sing\n"

    let page1Content = " Page 1 Top Left Text Box Dreamy dream of dreams\nPage 1 Top Right Text Box Catty cats from Cartland\nPage 1 Bottom left text box Rocky rocks in my rocks\nPage 1 Bottom right text box Sing sing sing\n \n"

    let page1ContentNoWhitespace = "Page1TopLeftTextBoxDreamydreamofdreamsPage1TopRightTextBoxCattycatsfromCartlandPage1BottomlefttextboxRockyrocksinmyrocksPage1BottomrighttextboxSingsingsing"

    let page2Content = " Page 2 Top Left Text Box Dreamy dream of dreams\nPage 2 Top Right Text Box Catty cats from Cartland\nPage 2 Bottom left text box Rocky rocks in my rocks\nPage 2 Bottom right text box Sing sing sing\n"

    let page1TopLeft = "Page 1 Top Left Text Box Dreamy dream of dreams\n"

    let page2TopRight = "Page 2 Top Right Text Box Catty cats from Cartland\n"

    enum PDFSourceTestError: Error {
        case couldNotFindTestFile
        case couldNotInitWithTestFile
        case invalidPDF
    }

    private func testDocumentURL() throws -> URL {
        guard let url = Bundle.module.url(forResource: "pdftestfile", withExtension: "pdf") else {
            throw PDFSourceTestError.couldNotFindTestFile
        }
        return url
    }

    private func testDocument() throws -> PDFDocument {
        let url = try testDocumentURL()
        guard let document = PDFDocument(url: url) else {
            throw PDFSourceTestError.invalidPDF
        }
        return document
    }

    override func setUpWithError() throws {
        testObject = PDFSource.init(url: try testDocumentURL())
        if testObject == nil {
            throw PDFSourceTestError.couldNotInitWithTestFile
        }
    }

    func test_init_givenBadURL_thenReturnNil() {
        let url = URL(fileURLWithPath: "/fakepath/fakefile.pdf")
        let localTestObject = PDFSource(url: url)
        XCTAssertNil(localTestObject)
    }

    func test_init_givenDocument_thenReturn() throws {
        let testDocument = try testDocument()
        let localTestObject = PDFSource(pdfDocument: testDocument)
        XCTAssertNotNil(localTestObject)
    }

    // MARK: - READING CONTENT

    // MARK: - TEXT FOR RANGE

    func test_textForRange_givenAllPages_ReturnAllText() async {
        let range = PDFContentSource(start: 0, end: 1, rect: nil)
        let result = await testObject?.text(for: range)
        XCTAssertEqual(result, fullContent)
    }

    func test_textForRange_givenFirstPage_ReturnPage1() async {
        let range = PDFContentSource(start: 0, end: 0, rect: nil)
        let result = await testObject?.text(for: range)
        XCTAssertEqual(result, page1Content)
    }

    func test_textForRange_givenLastPage_ReturnPage2() async {
        let range = PDFContentSource(start: 1, end: 1, rect: nil)
        let result = await testObject?.text(for: range)
        XCTAssertEqual(result, page2Content)
    }

    func test_textForRange_givenInvalidEndBeforeBegin_ReturnEmpty() async {
        let range = PDFContentSource(start: 1, end: 0, rect: nil)
        let result = await testObject?.text(for: range)
        XCTAssertEqual(result, "")
    }

    func test_textForRange_givenStartBeyondDocument_ReturnEmpty() async {
        let range = PDFContentSource(start: 5, end: 7, rect: nil)
        let result = await testObject?.text(for: range)
        XCTAssertEqual(result, "")
    }

    func test_textForRange_givenEndRangeBeyondDocument_ReturnContent() async {
        let range = PDFContentSource(start: 0, end: 7, rect: nil)
        let result = await testObject?.text(for: range)
        XCTAssertEqual(result, fullContent)
    }

    func test_textForRange_givenFirstPageRemoveWhitespace_ReturnPage1NoWhitespace() async {
        let range = PDFContentSource(start: 0, end: 0, rect: nil, removeWhitespace: true)
        let result = await testObject?.text(for: range)
        XCTAssertEqual(result, page1ContentNoWhitespace)
    }

    // MARK: - Text For Rect

    func test_textForRect_givenPage1TopLeftRect_thenReturnExpectedText() async {
        let rect = PDFContentSource(start: 0, end: 0, rect: CGRect(x: 0.0,
                                               y: 0.5,
                                               width: 0.5,
                                               height: 0.5))
        let result = await testObject?.text(for: rect)
        XCTAssertEqual(result, page1TopLeft)
    }

    func test_textForRect_givenPage1TopRightRect_thenReturnExpectedText() async {
        let rect = PDFContentSource(start: 1, end: 1, rect: CGRect(x: 0.5,
                                               y: 0.5,
                                               width: 0.5,
                                               height: 0.5))
        let result = await testObject?.text(for: rect)
        XCTAssertEqual(result, page2TopRight)
    }


    func test_textForRect_giveninvalidPage_thenReturnExpectedText() async {
        let rect = PDFContentSource(start: 3, end: 3, rect: CGRect(x: 0.5,
                                               y: 0.5,
                                               width: 0.5,
                                               height: 0.5))
        let result = await testObject?.text(for: rect)
        XCTAssertEqual(result, "")
    }

    func test_textForRect_givenPage1TopRightRectRemoveWhitespace_thenReturnExpectedText() async {
        let rect = PDFContentSource(start: 1, end: 1, rect: CGRect(x: 0.5,
                                               y: 0.5,
                                               width: 0.5,
                                               height: 0.5),
                                  removeWhitespace: true)
        let result = await testObject?.text(for: rect)
        XCTAssertEqual(result, "Page2TopRightTextBoxCattycatsfromCartland")
    }

    func test_textUnspecified_theReturnAllText() async {
        let result = await testObject?.text(for: nil)
        XCTAssertEqual(result, page1Content + page2Content)
    }

    func test_asynctest_givenMultipleCalls_thenReturnCached() async {
        let rect = PDFContentSource(start: 1, end: 1, rect: CGRect(x: 0.5,
                                               y: 0.5,
                                               width: 0.5,
                                               height: 0.5),
                                    removeWhitespace: true)
        let result1 = await testObject?.text(for: rect)
        let result2 = await testObject?.text(for: rect)
        let result3 = await testObject?.text(for: rect)
        let result4 = await testObject?.text(for: rect)
        XCTAssertEqual(result1, "Page2TopRightTextBoxCattycatsfromCartland")
        XCTAssertEqual(result2, "Page2TopRightTextBoxCattycatsfromCartland")
        XCTAssertEqual(result3, "Page2TopRightTextBoxCattycatsfromCartland")
        XCTAssertEqual(result4, "Page2TopRightTextBoxCattycatsfromCartland")
    }

    // MARK: - Page Width

    func test_pageWidth_givenSouce_thenReturnValue() async {
        let width = await testObject?.pageWidth()
        XCTAssertEqual(width, 612)
    }

    func test_pageWidth_givenSoucePage0_thenReturnValue() async {
        let width = await testObject?.pageWidth(for: 0)
        XCTAssertEqual(width, 612)
    }

    func test_pageWidth_givenSoucePage1_thenReturnValue() async {
        let width = await testObject?.pageWidth(for: 1)
        XCTAssertEqual(width, 612)
    }
}
