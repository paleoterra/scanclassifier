//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation
import PDFKit

public struct TypeMatcher: Codable {
    public var textMatchSets: [TextMatchSet]

    func match(for document: PDFDocument) -> TypeMatchScore {
        TypeMatchScore(results: textMatchSets.map { matchSet in
            matchSet.match(for: document)
        })

    }
}
