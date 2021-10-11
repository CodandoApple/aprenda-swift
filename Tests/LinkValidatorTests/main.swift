import Foundation
import XCTest
@testable import LinkValidator

class LinksTest : XCTestCase {
    
    var regex: NSRegularExpression?
    
    override func setUp() {
        do {
            regex = try NSRegularExpression(pattern: #"(?:\[.*\])\((?<link>.*)\)"#)
        } catch(let error) {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLinks() throws {
        
        let text = try LinkValidator.shared.readFileText("README.md")
        
        XCTAssertNotNil(text, "Foi impossível ler o arquivo README.md")
        XCTAssertGreaterThan(text.count, 0, "O arquivo está vazio")
        
        let textRange = NSRange(text.startIndex..., in: text)
        let links: [String]? = regex?.matches(in: text, options: [], range: textRange)
            .map {
                let matchRange = Range($0.range(withName: "link"), in: text)!
                return String(text[matchRange])
            }.filter { $0.starts(with: "http") }
        
        XCTAssertGreaterThan(links?.count ?? 0, 0, "URLS não encontrados no arquivo")
        XCTAssertNotNil(links, "A lista de links não foi obtida")
        
        for link in links! {
            let expectation = XCTestExpectation(description: "Carregar a página \(link)")

            let url = URL(string: link)!
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data,response,error) in
                XCTAssertNil(error, "A página \(link) não foi encontrada")
                if let httpResponse = response as? HTTPURLResponse {
                    XCTAssertEqual(httpResponse.statusCode, 200,
                                   String(format: "A página %@ não está disponível", httpResponse.url?.absoluteString ?? ""))
                } else {
                    XCTFail(String(format: "A página %@ falhou", link))
                }
                expectation.fulfill()
            })
            task.resume()
            wait(for: [expectation], timeout: 5.0)
        }
        
    }
}


