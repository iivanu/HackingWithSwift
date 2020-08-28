//
//  Petition.swift
//  Project9
//
//  Created by Ivan Ivanušić on 27/08/2020.
//  Copyright © 2020 Ivan Ivanušić. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
