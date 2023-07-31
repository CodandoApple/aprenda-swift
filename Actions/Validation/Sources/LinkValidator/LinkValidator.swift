import Foundation

class LinkValidator {
    
    public static var shared: LinkValidator = {
        LinkValidator()
    }()
    
    @available(macOS 12.0, *)
    func fetchText() async throws -> String {
        let url = URLRequest(url: URL(string: "https://raw.githubusercontent.com/CodandoApple/aprenda-swift/main/README.md")!)
        
        let (data, _) = try await URLSession.shared.data(for: url)
        
        return String(decoding: data, as: UTF8.self)
    }
}
