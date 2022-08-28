import Foundation
import PDFKit

public struct PDFContentSource: Codable {
    public var start: Int
    public var end: Int
    public var rect: CGRect?
    public var removeWhitespace: Bool

    public init(start: Int,
                end: Int,
                rect: CGRect?,
                removeWhitespace: Bool = false) {
        self.rect = rect
        self.start = start
        self.end = end
        self.removeWhitespace = removeWhitespace
    }

    public var descriptionString: String {
        "\(String(describing: rect))_\(start)_\(end)_\(removeWhitespace)"
    }
}
