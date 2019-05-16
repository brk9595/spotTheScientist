//
//  Scientists.swift
//  spotTheScientist
//
//  Created by Bharath  Raj kumar on 13/05/19.
//  Copyright © 2019 Bharath Raj Kumar. All rights reserved.
//

import Foundation

struct Scientist: Decodable
{
    let name: String
    let dates: String
    let field: String
    let bio: String
    let country: String
    let source: String
}

