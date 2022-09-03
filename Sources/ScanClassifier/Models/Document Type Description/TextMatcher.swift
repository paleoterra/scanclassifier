//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation
import PDFKit
protocol TextMatcherProtocol {
    func match(for document: PDFSourceProtocol, verbose: Bool) async -> Bool
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
    public var contentSource: PDFContentSource?

    public init(text: String,
                matchingOption: TextMatchOption?,
                clearWhiteSpace: Bool,
                contentSource: PDFContentSource?) {
        self.text = text
        self.matchingOption = matchingOption
        self.clearWhiteSpace = clearWhiteSpace
        self.contentSource = contentSource
    }

    func match(for document: PDFSourceProtocol, verbose: Bool) async -> Bool {
        var contentString = await document.text(for: contentSource)
        if clearWhiteSpace {
            contentString = contentString.filter { !$0.isWhitespace }
        }
        let result = contentString.range(of: text, options: .caseInsensitive, range: nil, locale: nil) != nil
        Logging.verbosePrint(verbose: verbose, content: "Matching String: \(text), cleared whitespace: \(clearWhiteSpace),  result: \(result)")
        return result
    }
}
