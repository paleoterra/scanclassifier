//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/28/22.
//

import Foundation

public struct People: Codable {
    let tag: String
    let names: [String]

    public init(tag: String, names: [String]) {
        self.tag = tag
        self.names = names
    }
}
