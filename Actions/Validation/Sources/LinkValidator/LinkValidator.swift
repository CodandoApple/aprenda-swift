import Foundation

class LinkValidator {
    
    public static var shared: LinkValidator = {
        return LinkValidator()
    }()
    
    @available(macOS 10.11, *)
    func readFileText(_ filename: String) throws -> String {
        if let fileURL = Bundle.main.path(forResource: filename, ofType: "md") {
            let text = try String(contentsOfFile: fileURL, encoding: .utf8)
            return text
        } else {
            let fileURL = URL(fileURLWithPath: "README.md")
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        }
    }
}
