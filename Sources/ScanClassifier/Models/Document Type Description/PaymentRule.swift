//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/28/22.
//

import Foundation

public struct PaymentRule: Codable {
    public let contentSource: PDFContentSource?

    public func paymentTag(for document: PDFSourceProtocol,
                            paymentTypes: [Payment],
                            prefixes: [String],
                            verbose: Bool) async -> String? {

        let text = await paymentText(for: document, verbose: verbose)

        let type =  paymentTypes.first { payment in
            processPayment(payment: payment, prefixes: prefixes, text: text, verbose: verbose)
        }
        return type?.tag
    }

    private func paymentText(for document: PDFSourceProtocol, verbose: Bool) async -> String {
        let text = await document.text(for: contentSource)
        return text.filter { !$0.isWhitespace }
    }

    private func processPayment(payment: Payment, prefixes: [String], text: String, verbose: Bool) -> Bool {
        if let _ = prefixes.first(where: { textPrefix in
            text.range(of: textPrefix, options: .caseInsensitive, range: nil, locale: nil) != nil
        }) {
            Logging.verbosePrint(verbose: verbose, content: "Matched Payment: \(payment.tag)")
            return true
        }
        return false
    }
}
