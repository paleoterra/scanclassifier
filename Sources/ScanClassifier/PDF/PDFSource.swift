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

    public func pageWidth(for page: Int = 0) async -> CGFloat {
        guard let page = pdfFile.page(at: page) else {
            return 0
        }
        return page.bounds(for: .mediaBox).width
    }

    public func text(for source: PDFContentSource?) async -> String {
        if let content = textCache[source?.descriptionString ?? allTextKey] {
            return await content.value
        } else {
            if let contentSource = source {
                let task = Task {
                    return text(for: contentSource)
                }
                textCache[contentSource.descriptionString] = task
                return await task.value
            }  else {
                let task = Task {
                    return allText()
                }
                textCache[allTextKey] = task
                return await task.value
            }
        }
    }

//    public func containsMatch(for matchString: String, options: String.CompareOptions, source: PDFContentSource?) -> Bool {
//        let matches = pdfFile.findString(matchString, withOptions: options)
//        guard !matches.isEmpty else {
//            return false
//        }
//        guard let source = source else {
//            return true
//        }
//        let validPages = (source.start...source.end).compactMap { page in
//            if page < pdfFile.pageCount {
//                return pdfFile.page(at: page)
//            }
//            return nil
//        }
//        let result = matches.compactMap { selection in
//            if let first = selection.pages.first, validPages.contains(first) {
//                if let rect = source.rect {
//                    let pageBounds = first.bounds(for: .mediaBox)
//                    let newRect = CGRect(x: rect.origin.x * pageBounds.size.width,
//                                         y: rect.origin.y * pageBounds.size.height,
//                                         width: rect.size.width * pageBounds.size.width,
//                                         height: rect.size.height * pageBounds.size.height)
//                    selection.
//                }
//            }
//            return false
//        }
//
//    }

    private func text(for source: PDFContentSource) -> String {
        var content: String = ""
        if source.start > source.end {
            return ""
        }
        for page in source.start...source.end {

            if let page = pdfFile.page(at: page) {
                if let rect = source.rect {
                    content.append(text(page: page, rect: rect))
                } else {
                    content.append(page.string ?? "")
                }
            }
        }
        if source.removeWhitespace {
            content = remoteWhiteSpace(from: content)
        }
        return content
    }

    private func text(page: PDFPage, rect: CGRect) -> String {
        let pageRect = calculateRect(for: page, rect: rect)
        if let selection = page.selection(for: pageRect), let result = selection.string {
            return result
        }
        return ""

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
