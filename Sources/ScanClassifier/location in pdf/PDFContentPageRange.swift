import Foundation
import PDFKit

public struct PDFContentPageRange: Codable, PDFContentSource {
    public var start: Int
    public var end: Int
    public var removeWhitespace: Bool

    public init(start: Int, end: Int, removeWhitespace: Bool = false) {
        self.start = start
        self.end = end
        self.removeWhitespace = removeWhitespace
    }

    public var descriptionString: String {
        "\(start)_\(end)_\(removeWhitespace)"
    }
}
