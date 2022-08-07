//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation
import PDFKit

public struct TextMatchSet: Codable {
    public let matchers: [TextMatcher]
    public let isRequired: Bool

    func match(for document: PDFDocument) -> MatchType {
        let firstMatcher = matchers.first { matcher in
            matcher.match(for: document)
        }
        if isRequired {
            return firstMatcher != nil ? .match : .failed
        } else {
            return firstMatcher != nil ? .optionalMatch : .optionalFailed
        }

    }
}
