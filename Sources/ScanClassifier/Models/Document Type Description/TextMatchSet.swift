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
    public let isAny: Bool

    func match(for document: PDFSourceProtocol, verbose: Bool) async -> MatchType {
        let matches = await matchers.asyncMap { matcher in
            await matcher.match(for: document, verbose: verbose)
        }
        let matched: Bool = isAny ? matches.contains(true) : !matches.contains(false)
        if isRequired {
            let result: MatchType = matched ? .match : .failed
            Logging.verbosePrint(verbose: verbose, content: "Text Match Set Result: \(result)")
            return result
        } else {
            let result: MatchType = matched ? .optionalMatch : .optionalFailed
            Logging.verbosePrint(verbose: verbose, content: "Text Match Set Result: \(result)")
            return result
        }

    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
