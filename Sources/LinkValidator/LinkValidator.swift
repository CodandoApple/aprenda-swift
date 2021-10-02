import Foundation

class LinkValidator {
    
    public static var shared: LinkValidator = {
        return LinkValidator()
    }()
    
    @available(macOS 10.11, *)
    func readFileText(_ filename: String) throws -> String {
        if let fileURL = Bundle.main.path(forResource: filename, ofType: "txt") {
            let text = try String(contentsOfFile: fileURL, encoding: .utf8)
            return text
        } else {
            let projectDirectory = URL(fileURLWithPath: ProcessInfo.processInfo.environment["SRCROOT"] ?? "")
            let fileURL = URL(fileURLWithPath: filename, relativeTo: projectDirectory)
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        }
    }
}
