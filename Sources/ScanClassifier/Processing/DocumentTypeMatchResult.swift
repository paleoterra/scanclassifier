//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/28/22.
//

import Foundation

public struct DocumentTypeMatchResult {
    public var dateString: String
    public var mainTags: [String]
    public var paymentTag: String?
    public var peopleTags: [String]
    public var className: String

    public func allTags() -> [String] {
        var tags = mainTags + peopleTags
        if let payment = paymentTag {
            tags.append(payment)
        }
        return tags
    }

    public func fileNameString() -> String {
        let tagString = allTags().reduce("") { partialResult, tag in
            if partialResult.isEmpty {
                return tag
            } else {
                return partialResult + ", " + tag
            }
        }
        return dateString + " - " + tagString
    }
}
