//
//  main.swift
//  
//
//  Created by Matheus dos Reis de Jesus on 02/08/23.
//

import Foundation
import LinkValidator

let validator = LinkValidator(urlSession: URLSession(configuration: .ephemeral))

let files = CommandLine.arguments[1...]

var invalidLinks: [Link] = []

for file in files {
    do {
        let text = try String(contentsOfFile: file)
        let links = await validator.validateLinksForText(text)
        invalidLinks.append(contentsOf: links)
    } catch {
        fatalError("File not found: \(file)")
    }
}

let separator = String(repeating: "=", count: 30)

if !invalidLinks.isEmpty {
    fatalError("""

\(separator)

Links validation failed for:
    
\(invalidLinks.map { $0.format() }.joined(separator: "\n"))

Please, fix or remove the links above to get your PR approved.

\(separator)

""")
}

print("All links are available. Good to go")
