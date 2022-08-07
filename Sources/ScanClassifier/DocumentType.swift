import Foundation
import PDFKit

public struct DocumentType: Codable {
    public var className: String
    public var textMatchers: TypeMatcher

    func match(for document: PDFDocument) -> TypeMatchScore {
        textMatchers.match(for: document)
    }

}
