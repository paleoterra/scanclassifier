//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation
import PDFKit

public struct TextMatcher: Codable {
    public enum TextMatchOption: String, Codable {
        case caseInsensitive
        case regularExpression
        case none
    }
    public var text: String
    public var matchingOption: TextMatchOption?
    public var clearWhiteSpace: Bool
    public var contentRect: PDFContentRect?
    public var contentRange: PDFContentPageRange?

    func match(for document: PDFDocument) -> Bool {
//        var contentString = ""
//        if let contentRect = contentRect {
//            contentString = contentRect.extractPDFContent(from: document)
//        } else if let contentRange = contentRange {
//            contentString = contentRange.extractPDFContent(from: document)
//        } else {
//            contentString = document.string ?? ""
//        }
//
//        if clearWhiteSpace {
//            contentString = contentString.filter { !$0.isWhitespace }
//        }
//        return contentString.range(of: text, options: .caseInsensitive, range: nil, locale: nil) != nil
        return false
    }
}
