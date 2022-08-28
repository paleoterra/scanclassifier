//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/28/22.
//

import Foundation

enum Logging {
    static func verbosePrint(verbose: Bool, content: String) {
        if verbose {
            print(content)
        }
    }
}
