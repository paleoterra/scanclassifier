import Foundation
import PDFKit

public struct PDFContentRect: Codable, PDFContentSource {
    public var rect: CGRect
    public var page: Int
    public var removeWhitespace: Bool

    public init(rect: CGRect, page: Int, removeWhitespace: Bool = false) {
        self.rect = rect
        self.page = page
        self.removeWhitespace = removeWhitespace
    }

    public var descriptionString: String {
        "\(String(describing: rect))_\(page)_\(removeWhitespace)"
    }
}
