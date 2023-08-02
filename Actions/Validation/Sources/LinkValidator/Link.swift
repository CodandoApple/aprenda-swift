//
//  Link.swift
//  
//
//  Created by Matheus dos Reis de Jesus on 02/08/23.
//

import Foundation

public struct Link: Equatable {
    public let name: String
    public let url: String
    public var isValid = false
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
    public mutating func validate(on urlSession: URLSession = .shared) async {

    }
    
    public func format() -> String {
        return String(format: "- %@: %@", name, url)
    }
    
    public static func ==(lhs: Link, rhs: Link) -> Bool {
        return lhs.name == rhs.name && lhs.url == rhs.url
    }
}
