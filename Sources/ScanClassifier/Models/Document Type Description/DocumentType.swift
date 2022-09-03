import Foundation
import PDFKit

public struct DocumentType: Codable, Identifiable {
    public var id: String = UUID().uuidString

    public var className: String
    public var typeMatcher: TypeMatcher
    public var dateStrategy: DateStrategy
    public var tags: [String]
    public var paymentRule: PaymentRule?
    public var peopleRule: PeopleRule?

    public init(className: String = "Unnamed",
                textMatchers: TypeMatcher = TypeMatcher(textMatchSets: [], documentWidth: .anySize),
                dateStrategy: DateStrategy = DateStrategy(),
                tags: [String] = [],
                creditCard: PaymentRule? = nil,
                peopleRule: PeopleRule? = nil) {
        self.className = className
        self.typeMatcher = textMatchers
        self.dateStrategy = dateStrategy
        self.tags = tags
        self.paymentRule = creditCard
        self.peopleRule = peopleRule
    }

    func match(for document: PDFSourceProtocol, verbose: Bool) async -> TypeMatchScore {
        await typeMatcher.match(for: document, verbose: verbose)
    }

    public func dateString(for document: PDFSourceProtocol, verbose: Bool) async -> String {
        return await dateStrategy.dateString(for: document, verbose: verbose)
    }

    public func peopleTags(for document: PDFSourceProtocol, people: [People], verbose: Bool) async -> [String] {

        await peopleRule?.peopleTags(for: document, people: people, verbose: verbose) ?? []
    }

    public func paymentTag(for document: PDFSourceProtocol,
                           payment: [Payment],
                           prefixes: [String],
                           verbose: Bool) async -> String? {
        guard let paymentRule = paymentRule else {
            return nil
        }
        return await paymentRule.paymentTag(for: document,
                               paymentTypes: payment, prefixes: prefixes, verbose: verbose)
    }
}
