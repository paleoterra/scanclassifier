//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation
import PDFKit

/// The type matcher is the portion of the matching system that matches
/// to the Document type.
public struct TypeMatcher: Codable, Identifiable {
    public var id = UUID().uuidString
    public var textMatchSets: [TextMatchSet]
    public var documentWidth: DocumentWidth

    public init(textMatchSets: [TextMatchSet] = [],
                documentWidth: DocumentWidth) {
        self.textMatchSets = textMatchSets
        self.documentWidth = documentWidth
    }

    func match(for document: PDFSourceProtocol, verbose: Bool) async -> TypeMatchScore {
        var matches: [MatchType] = []
        matches.append(documentWidth.match(width: await document.pageWidth(for: 0), verbose: verbose))
        matches.append(contentsOf: await textMatchSets.asyncMap { matchSet in
            await matchSet.match(for: document, verbose: verbose)
        })
        return TypeMatchScore(results: matches)

    }
}
