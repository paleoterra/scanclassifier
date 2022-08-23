//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation
import PDFKit
protocol TextMatcherProtocol {
    func match(for document: PDFSourceProtocol) async -> Bool
}

public struct TextMatcher: TextMatcherProtocol, Codable {
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

    public init(text: String,
                matchingOption: TextMatchOption?,
                clearWhiteSpace: Bool,
                contentRect: PDFContentRect?,
                contentRange: PDFContentPageRange?) {
        self.text = text
        self.matchingOption = matchingOption
        self.clearWhiteSpace = clearWhiteSpace
        self.contentRect = contentRect
        self.contentRange = contentRange
    }

    func match(for document: PDFSourceProtocol) async -> Bool {
        var contentString = await document.text(for: contentRule())
        if clearWhiteSpace {
            contentString = contentString.filter { !$0.isWhitespace }
        }
        return contentString.range(of: text, options: .caseInsensitive, range: nil, locale: nil) != nil
    }

    private func contentRule() -> PDFContentSource? {
        if let sourceRect = contentRect {
            return sourceRect
        } else if let sourceRange = contentRange {
            return sourceRange
        }
        return nil
    }
}
