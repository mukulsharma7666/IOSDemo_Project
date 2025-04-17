//
//  Product.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import Foundation

struct Product: Codable, Equatable {
    let id: Int
    let name: String
    let imageName: String
    let price: String
}
