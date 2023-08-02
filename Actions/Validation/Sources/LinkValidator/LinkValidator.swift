import Foundation

public final class LinkValidator {

    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    private let regex = try! NSRegularExpression(pattern: #"(?:\-\s?\[(?<name>.*)\])\((?<link>.*)\)"#)
    
    public func validateLink(link: inout Link) async {
        guard let url = URL(string: link.url),
              let (_, response) = try? await urlSession.data(from: url),
              let httpResponse = response as? HTTPURLResponse else {
            return
        }
        
        link.isValid = (200...299).contains(httpResponse.statusCode)
    }
    
    public func validateLinksForText(_ text: String) async -> [Link] {
        let links = extractLinksFromText(text)
        
        return await withTaskGroup(of: Link.self) { group in
            for index in 0..<links.count {
                group.addTask {
                    var link = links[index]
                    await self.validateLink(link: &link)
                    return link
                }
            }
            
            var invalidLinks: [Link] = []
            
            for await link in group {
                guard !link.isValid else { continue }
                invalidLinks.append(link)
            }
            
            return invalidLinks
        }
    }
    
    public func extractLinksFromText(_ text: String) -> [Link] {
        let textRange = NSRange(text.startIndex..., in: text)
        
        return regex.matches(in: text, options: [], range: textRange)
            .map {
                let nameRange = Range($0.range(withName: "name"), in: text)!
                let linkRange = Range($0.range(withName: "link"), in: text)!
                
                return Link(name: String(text[nameRange]),
                            url: String(text[linkRange]))
            }
    }
}
