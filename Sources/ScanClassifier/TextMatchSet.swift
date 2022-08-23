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

    func match(for document: PDFSource) async -> MatchType {
        let matches = await matchers.asyncMap { matcher in
            await matcher.match(for: document)
        }
        let failed = matches.compactMap { $0 == true ? nil : false }
        if isRequired {
            return failed.isEmpty ? .match : .failed
        } else {
            return failed.isEmpty ? .optionalMatch : .optionalFailed
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
