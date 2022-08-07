//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation

public class SourceClassifier {
    enum SourceClassifierError: Error {
        case noClassificationRules
    }

    public var documentTypes: [DocumentType] = []

    public init() {

    }

    public init(documentTypeURL: URL) throws {
        let data = try Data(contentsOf: documentTypeURL)
        self.documentTypes = try JSONDecoder().decode([DocumentType].self, from: data)

    }

    public func store(url: URL) throws {
        if documentTypes.isEmpty {
            throw SourceClassifierError.noClassificationRules
        }
        let data = try JSONEncoder().encode(documentTypes)
        try data.write(to: url)
    }
}
