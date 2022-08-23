import Foundation
import PDFKit

public protocol PDFSourceProtocol {
    func pageWidth(for page: Int) async -> CGFloat
    func text(for source: PDFContentSource?) async -> String

}

public actor PDFSource: PDFSourceProtocol {
    var pdfFile: PDFDocument
    var textCache: [String: Task<String, Never>] = [:]
    private let allTextKey = "allTextKey"

    public init(pdfDocument: PDFDocument) {
        self.pdfFile = pdfDocument
    }

    public init?(url: URL) {
        guard let file = PDFDocument(url: url) else {
            return nil
        }
        self.pdfFile = file
    }

    public func pageWidth(for page: Int = 0) -> CGFloat {
        guard let page = pdfFile.page(at: page) else {
            return 0
        }
        return page.bounds(for: .mediaBox).width
    }

    public func text(for source: PDFContentSource?) async -> String {
        if let content = textCache[source?.descriptionString ?? allTextKey] {
            return await content.value
        } else {
            if let sourceRect = source as? PDFContentRect {
                let task = Task {
                    return text(for: sourceRect)
                }
                textCache[sourceRect.descriptionString] = task
                return await task.value
            } else if let sourceRange = source as? PDFContentPageRange {
                let task = Task {
                    return text(for: sourceRange)
                }
                textCache[sourceRange.descriptionString] = task
                return await task.value
            } else {
                let task = Task {
                    return allText()
                }
                textCache[allTextKey] = task
                return await task.value
            }
        }
    }

    private func text(for source: PDFContentRect) -> String {
        var content: String = ""
        if let page = pdfFile.page(at: source.page) {
            let pageRect = calculateRect(for: page, rect: source.rect)
            if let selection = page.selection(for: pageRect), let result = selection.string {
                content = result
            }
        }

        if source.removeWhitespace {
            content = remoteWhiteSpace(from: content)
        }
        return content
    }

    private func text(for source: PDFContentPageRange) -> String {
        var content: String = ""
        if source.start > source.end {
            return ""
        }
        for page in source.start...source.end {
            if let page = pdfFile.page(at: page), let pageContent = page.string {
                content.append(pageContent)
            }
        }
        if source.removeWhitespace {
            content = remoteWhiteSpace(from: content)
        }
        return content
    }

    private func allText() -> String {
        var content = ""
        for pageNumber in 0..<pdfFile.pageCount {
            if let page = pdfFile.page(at: pageNumber) {
                content = content + (page.string ?? "")
            }
        }
        return content
    }

    private func remoteWhiteSpace(from sourceString: String) -> String {
        sourceString.filter { !$0.isWhitespace }
    }

    private func calculateRect(for page: PDFPage, rect: CGRect) -> CGRect {
        let size = page.bounds(for: PDFDisplayBox.mediaBox)
        return CGRect(x: rect.origin.x * size.width,
                      y: rect.origin.y * size.height,
                      width: rect.size.width * size.width,
                      height: rect.size.height * size.height)
    }
}
