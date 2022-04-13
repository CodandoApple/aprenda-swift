import Foundation
import XCTest
@testable import LinkValidator

class LinksTest : XCTestCase {
    
    var queue: [String] = []
    var triesCount: [String:Int] = [:]
    var regex: NSRegularExpression?
    
    override func setUp() {
        do {
            regex = try NSRegularExpression(pattern: #"(?:\[.*\])\((?<link>.*)\)"#)
        } catch(let error) {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLinks() throws {
        
        do {
            let text = try LinkValidator.shared.readFileText("README")
            
            XCTAssertNotNil(text, "Foi impossível ler o arquivo README.md")
            XCTAssertGreaterThan(text.count, 0, "O arquivo está vazio")
            
            self.queue = extractLinksFromText(text)
            
            XCTAssertGreaterThan(queue.count, 0, "URLS não encontrados no arquivo")
            
            while !queue.isEmpty {
                guard let link = queue.last, let url = URL(string: link) else { continue }
                
                let expectation = XCTestExpectation(description: "Carregar a página \(link)")
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data,response,error) in
                    XCTAssertNil(error, "A página \(link) não foi encontrada")
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        XCTAssertTrue((200...299).contains(httpResponse.statusCode),"A página \(link) não está disponível")
                        let _ = self.queue.popLast()
                    } else {
                        if let count = self.triesCount[link] {
                            if count == 3 {
                                let _ = self.queue.popLast()
                                XCTFail("A página \(link) está fora do ar")
                            } else {
                                self.triesCount[link] = count + 1
                            }
                        } else {
                            self.triesCount[link] = 1
                        }
                    }
                    expectation.fulfill()
                })
                task.resume()
                wait(for: [expectation], timeout: 10.0)
            }
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
        
    }
}

extension LinksTest {
    private func extractLinksFromText(_ text: String) -> [String] {
        guard let regex = regex else { return [] }
        let textRange = NSRange(text.startIndex..., in: text)
        
        return regex.matches(in: text, options: [], range: textRange)
            .map {
                let matchRange = Range($0.range(withName: "link"), in: text)!
                return String(text[matchRange])
            }.filter { $0.starts(with: "http") }
    }
}


