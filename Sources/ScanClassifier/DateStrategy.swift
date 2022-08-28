//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/28/22.
//

import Foundation

public enum DateSelectionOrder: String, Codable {
    case first
    case last
    case newest
    case oldest
}

public struct DateStrategy {
    public let contentSource: PDFContentSource?
    public let leadingText: String?
    public let trailingText: String?
    public let order: DateSelectionOrder?
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    public init(contentSource: PDFContentSource? = nil, leadingText: String? = nil, trailingText: String? = nil, order: DateSelectionOrder? = nil) {
        self.contentSource = contentSource
        self.leadingText = leadingText
        self.trailingText = trailingText
        self.order = order
    }

    public func dateString(for document: PDFSourceProtocol, verbose: Bool) async -> String {
        return await dateText(for: document)
    }

    private func dateText(for document: PDFSourceProtocol) async -> String {
        var text = await document.text(for: contentSource)
        text = removeLeading(from: text)
        text = removeTrailing(from: text)
        let dates = findDates(in: text)
        if dates.isEmpty {
            return ""
        }
        guard let date = applyDateStrategy(dates: dates) else {
            return ""
        }
        return DateStrategy.dateFormatter.string(from: date)

    }

    private func removeLeading(from text: String) -> String {
        guard let leading = leadingText else {
            return text
        }

        if let result = text.range(of: leading, options: .caseInsensitive, range: nil, locale: nil) {
            let mySubstring = text.suffix(from: result.upperBound)
            return String(mySubstring)
        } else {
            return text
        }
    }

    private func removeTrailing(from text: String) -> String {
        guard let trailingText = trailingText else {
            return text
        }

        if let result = text.range(of: trailingText, options: .caseInsensitive, range: nil, locale: nil) {
            let mySubstring = text.prefix(upTo: result.lowerBound)
            return String(mySubstring)
        } else {
            return text
        }
    }

    private func findDates(in text: String) -> [Date] {
        var allDates: [Date] = []
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return allDates
        }
        let matches = detector.matches(in: text, options: [],
                                       range: NSRange(location: 0, length: text.utf16.count))
        allDates = matches.compactMap({ result in
            result.date
        })
        return allDates
    }

    private func applyDateStrategy(dates: [Date]) -> Date? {
        var preferredDate = dates.first
        let sorted = dates.sorted { lhs, rhs in
            lhs > rhs
        }
        switch order ?? .first {
        case .last:
            preferredDate = dates.last
        case .newest:
            preferredDate = sorted.first
        case .oldest:
            preferredDate = sorted.last
        default:
            break
        }
        return preferredDate
    }
}
