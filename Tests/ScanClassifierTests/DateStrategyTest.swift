//
//  DateStrategyTest.swift
//  
//
//  Created by Thomas Moore on 8/28/22.
//

import XCTest
import ScanClassifier

final class DateStrategyTest: XCTestCase {

    let exampleText1 = "This is a partyharty on 03/04/1972 but could be December 12, 1969 in the future"
    let example1Date1 = "1972-03-04"
    let example1Date2 = "1969-12-12"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func test_dateStringWithNoSettings() async {
        let testObject = DateStrategy()
        let mockPDF = MockPDFSource()
        mockPDF.textStringToReturn = exampleText1
        let result = await testObject.dateString(for: mockPDF, verbose: false)
        XCTAssertEqual(result, example1Date1)
    }

    func test_dateString_leadingText_thenDateAfterLeading() async {
        let testObject = DateStrategy(leadingText: "but could be")
        let mockPDF = MockPDFSource()
        mockPDF.textStringToReturn = exampleText1
        let result = await testObject.dateString(for: mockPDF, verbose: false)
        XCTAssertEqual(result, example1Date2)
    }

    func test_dateString_trailingText_thenDateAfterLeading() async {
        let testObject = DateStrategy(trailingText: "but could be")
        let mockPDF = MockPDFSource()
        mockPDF.textStringToReturn = exampleText1
        let result = await testObject.dateString(for: mockPDF, verbose: false)
        XCTAssertEqual(result, example1Date1)
    }

    func test_dateString_orderFirst_thenDateAfterLeading() async {
        let testObject = DateStrategy(order: .first)
        let mockPDF = MockPDFSource()
        mockPDF.textStringToReturn = exampleText1
        let result = await testObject.dateString(for: mockPDF, verbose: false)
        XCTAssertEqual(result, example1Date1)
    }

    func test_dateString_orderLast_thenDateAfterLeading() async {
        let testObject = DateStrategy(order: .last)
        let mockPDF = MockPDFSource()
        mockPDF.textStringToReturn = exampleText1
        let result = await testObject.dateString(for: mockPDF, verbose: false)
        XCTAssertEqual(result, example1Date2)
    }

    func test_dateString_orderNewest_thenDateAfterLeading() async {
        let testObject = DateStrategy(order: .newest)
        let mockPDF = MockPDFSource()
        mockPDF.textStringToReturn = exampleText1
        let result = await testObject.dateString(for: mockPDF, verbose: false)
        XCTAssertEqual(result, example1Date1)
    }

    func test_dateString_orderOldest_thenDateAfterLeading() async {
        let testObject = DateStrategy(order: .oldest)
        let mockPDF = MockPDFSource()
        mockPDF.textStringToReturn = exampleText1
        let result = await testObject.dateString(for: mockPDF, verbose: false)
        XCTAssertEqual(result, example1Date2)
    }

}
