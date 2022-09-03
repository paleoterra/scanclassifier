//
//  File.swift
//  
//
//  Created by Thomas Moore on 9/3/22.
//

import Foundation

struct PaymentFileModel: Codable {
    let scanPrefixes: [String]
    let paymentTypes: [Payment]
}
