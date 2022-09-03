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
        case notValidFileOrDirectory
        case noDocumentTypeRulesFound
    }

    enum ClassifierExtensions: String {
        case documentType = "documentType"
        case peopleRules = "people"
        case paymentRules = "payment"
    }

    public var documentTypes: [DocumentType] = []
    public var people: [People] = []
    public var payments: [Payment] = []
    public var paymentPrefixes: [String] = []

    // MARK: - Init
    public init(documentTypesDirectory: URL,
                peopleRulesFileOrDirectory: URL?,
                paymentFileOrDirectory: URL?) throws {

        try setDocumentTypes(from: documentTypesDirectory)

        if let peopleUrl = peopleRulesFileOrDirectory {
            try setPeopleRules(from: peopleUrl)
        }
    }

    convenience public init(rulesDirectory: URL) throws {
        try self.init(documentTypesDirectory: rulesDirectory,
                  peopleRulesFileOrDirectory: rulesDirectory,
                  paymentFileOrDirectory: rulesDirectory)
    }

    // MARK: - Find Files

    private func findFiles(url: URL, pathExtension: String) -> [URL] {
        guard let result = try? isDirectory(url: url) else {
            return []
        }
        if !result, url.pathExtension == pathExtension {
            return [url]
        } else {
            return (try? locateRules(url: url, pathExtension: pathExtension)) ?? []
        }
    }

    private func isDirectory(url: URL) throws -> Bool {
        guard let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey]), let isDir = resourceValues.isDirectory else {
            throw SourceClassifierError.notValidFileOrDirectory
        }
        return isDir
    }

    private func locateRules(url: URL, pathExtension: String) throws -> [URL] {
        var docUrls: [URL] = []
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == pathExtension {
                    docUrls.append(fileURL)
                }
            }
        }
        if docUrls.isEmpty {
            throw SourceClassifierError.noDocumentTypeRulesFound
        }
        return docUrls
    }

    // MARK: - Document Types

    private func setDocumentTypes(from url: URL) throws {
        let documentTypeURLS = try locateRules(url: url, pathExtension: ClassifierExtensions.documentType.rawValue)
        loadDocumentRules(urls: documentTypeURLS)
    }

    private func loadDocumentRules(urls: [URL]) {
        let decoder = JSONDecoder()
        urls.forEach { url in
            if url.pathExtension == "documentType" {
                do {
                    let data = try Data.init(contentsOf: url)
                    let type = try decoder.decode(DocumentType.self, from: data)
                    documentTypes.append(type)
                } catch {
                    print("Could not read document type at \(url): error \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Payment

    private func setPaymentRules(from url: URL) throws {
        let paymentURLS = try locateRules(url: url, pathExtension: ClassifierExtensions.paymentRules.rawValue)
        loadPayment(urls: paymentURLS)
    }

    private func loadPayment(urls: [URL]) {
        let decoder = JSONDecoder()
        urls.forEach { url in
            if url.pathExtension == ClassifierExtensions.paymentRules.rawValue {
                do {
                    let data = try Data.init(contentsOf: url)
                    let rules = try decoder.decode(PaymentFileModel.self, from: data)
                    paymentPrefixes.append(contentsOf: rules.scanPrefixes)
                    payments.append(contentsOf: rules.paymentTypes)
                } catch {
                    print("Could not read payment file at \(url): error \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - People

    private func setPeopleRules(from url: URL) throws {
        let peopleURLS = try locateRules(url: url, pathExtension: ClassifierExtensions.peopleRules.rawValue)
        loadPeople(urls: peopleURLS)
    }

    private func loadPeople(urls: [URL]) {
        let decoder = JSONDecoder()
        urls.forEach { url in
            if url.pathExtension == ClassifierExtensions.peopleRules.rawValue {
                do {
                    let data = try Data.init(contentsOf: url)
                    let rules = try decoder.decode([People].self, from: data)
                    people.append(contentsOf: rules)
                } catch {
                    print("Could not read people file at \(url): error \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Classify

    public func classifyMatches(url: URL, verbose: Bool = false) async throws -> DocumentTypeMatchResult? {
        guard let pdf = PDFSource(url: url) else {
            throw SourceClassifierError.failedToOpenFile
        }

        Logging.verbosePrint(verbose: verbose, content: "Working on: \(url.lastPathComponent)")
        var matchType: DocumentType?
        for docType in documentTypes {
            Logging.verbosePrint(verbose: verbose, content: "Evaluating: \(docType.className)")
            let match = await docType.match(for: pdf, verbose: verbose)
            if match.isMatched {
                Logging.verbosePrint(verbose: verbose, content: "Matched for: \(docType.className)")
                matchType = docType
                break
            }
        }
        guard let matchType = matchType else {
            return nil
        }
        var result = DocumentTypeMatchResult(dateString: "", mainTags: [], paymentTag: nil, peopleTags: [])
        result.dateString = await matchType.dateString(for: pdf, verbose: verbose)
        result.mainTags = matchType.tags
        result.peopleTags = await matchType.peopleTags(for: pdf, people: people, verbose: verbose)

        result.paymentTag = await matchType.paymentTag(for: pdf, payment: payments, prefixes: paymentPrefixes, verbose: verbose)

        Logging.verbosePrint(verbose: verbose, content: result.fileNameString())
        return result

    }
}
