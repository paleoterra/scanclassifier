//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/21/22.
//

import Foundation
import ScanClassifier

class MockPDFSource: PDFSourceProtocol {

    var pageWidthReturnValue: CGFloat = 0
    var pageWidthCalled = false
    func pageWidth(for page: Int) async -> CGFloat {
        pageWidthCalled = true
        return pageWidthReturnValue
    }

    var capturedPDFContentSource: PDFContentSource?
    var textForCalled = false
    var textStringToReturn = ""
    func text(for source: ScanClassifier.PDFContentSource?) async -> String {
        textForCalled = true
        if let capturedSource = source  {
            capturedPDFContentSource = capturedSource
        }
        return textStringToReturn
    }


}
