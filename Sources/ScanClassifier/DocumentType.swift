import Foundation
import PDFKit

public struct DocumentType: Codable, Identifiable {
    public var id: String = UUID().uuidString

    public var className: String
    public var typeMatcher: TypeMatcher

    public init(className: String = "Unnamed",
                textMatchers: TypeMatcher = TypeMatcher(textMatchSets: [], documentWidth: .anySize)) {
        self.className = className
        self.typeMatcher = textMatchers
    }

    func match(for document: PDFSourceProtocol, verbose: Bool) async -> TypeMatchScore {
        await typeMatcher.match(for: document, verbose: verbose)
    }


}
