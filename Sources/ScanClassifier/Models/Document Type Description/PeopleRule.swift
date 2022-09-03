//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/28/22.
//

import Foundation

public struct PeopleRule: Codable {
    public let leadingText: String?
    public let trailingText: String?
    public let contentSource: PDFContentSource?


    public func peopleTags(for document: PDFSourceProtocol, people: [People], verbose: Bool) async -> [String] {

        let text = await peopleText(for: document, verbose: verbose)
        let names = people.compactMap { person -> String? in
            return processPerson(person: person, text: text)
        }
        return names
    }

    private func peopleText(for document: PDFSourceProtocol, verbose: Bool) async -> String {
        return await document.text(for: contentSource)
    }

    private func processPerson(person: People, text: String) -> String? {
        let updatedNamed = person.names.map { name in
            "\(leadingText ?? "")\(name)\(trailingText ?? "")"
        }
        if updatedNamed.first(where: {
            text.range(of: $0, options: .caseInsensitive, range: nil, locale: nil) != nil
        }) != nil {
            return person.tag
        } else {
            return nil
        }
    }

}
