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
        case failedToOpenFile
        case notValidDirectory
        case noDocumentTypeRulesFound
    }

    public var documentTypes: [DocumentType] = []

    public init() {

    }

    public init(rulesDirectory: URL) throws {
        try validateSourceDirectory(url: rulesDirectory)
        let documentTypeRuleURLs = try locateDocumentRules(url: rulesDirectory)
        loadRules(urls: documentTypeRuleURLs)
    }

    private func validateSourceDirectory(url: URL) throws {
        guard let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey]), let isDir = resourceValues.isDirectory, isDir == true else {
            throw SourceClassifierError.notValidDirectory
        }
    }

    private func locateDocumentRules(url: URL) throws -> [URL] {
        var docUrls: [URL] = []
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "documentType" {
                    docUrls.append(fileURL)
                }
            }
        }
        if docUrls.isEmpty {
            throw SourceClassifierError.noDocumentTypeRulesFound
        }
        return docUrls
    }

    private func loadRules(urls: [URL]) {
        let decoder = JSONDecoder()
        urls.forEach { url in
            do {
                let data = try Data.init(contentsOf: url)
                let type = try decoder.decode(DocumentType.self, from: data)
                documentTypes.append(type)
            } catch {
                print("Could not read document type at \(url): error \(error.localizedDescription)")
            }
        }
    }

    public init(documentTypeURL: URL) throws {
        print("loading json")
        let data = try Data(contentsOf: documentTypeURL)
        self.documentTypes = try JSONDecoder().decode([DocumentType].self, from: data)
        print("done json")
    }

    public func store(url: URL) throws {
        if documentTypes.isEmpty {
            throw SourceClassifierError.noClassificationRules
        }
        let data = try JSONEncoder().encode(documentTypes)
        try data.write(to: url)
    }

    public func classifyMatches(url: URL, verbose: Bool = false) async throws -> String {
        guard let pdf = PDFSource(url: url) else {
            throw SourceClassifierError.failedToOpenFile
        }

        Logging.verbosePrint(verbose: verbose, content: "Working on: \(url.lastPathComponent)")
        for docType in documentTypes {
            Logging.verbosePrint(verbose: verbose, content: "Evaluating: \(docType.className)")
            let match = await docType.match(for: pdf, verbose: verbose)
            if match.isMatched {
                Logging.verbosePrint(verbose: verbose, content: "Matched for: \(docType.className)")
                return docType.className
            }
        }
        Logging.verbosePrint(verbose: verbose, content: "No match")
        return "NO MATCH"

    }
}
