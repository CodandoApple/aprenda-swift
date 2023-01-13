import Foundation
import XCTest
@testable import LinkValidator

class LinksTest : XCTestCase {
    
    var queue: [String] = []
    var failures: [String] = []
    let urlSession = URLSession(configuration: .ephemeral)
    var triesCount: [String:Int] = [:]
    var regex: NSRegularExpression?
    let ignoreList = ["medium.com", "instagram.com"]
    
    override func setUp() {
        do {
            regex = try NSRegularExpression(pattern: #"(?:\-\s?\[.*\])\((?<link>.*)\)"#)
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
            
            XCTAssertGreaterThan(queue.count, 0, "URLS não encontradas no arquivo")
            
            while !queue.isEmpty {

                guard let link = queue.first , let url = URL(string: link) else {
                    if let first = queue.first {
                        debugPrint("O link \(first) apresentou algum problema e não pode ser validado")
                        removeFailedURL(link: first)
                    }
                    continue
                }

                if (!ignoreList.allSatisfy { !link.contains($0) }) {               
                    self.queue.removeAll { $0 == link }
                    continue
                }

                let expectation = XCTestExpectation(description: "Carregar a página \(link)")
                
                let task = urlSession.dataTask(with: url) { (data,response,error) in
                    
                    if let errorDescription = error?.localizedDescription {
                        XCTFail("Ocorreu um erro ao acessar o link \(link): \(errorDescription)")
                        self.removeFailedURL(link: link)
                        return
                    }
                    
                    if let count = self.triesCount[link] {
                        if count < 3 {
                            self.triesCount[link] = count + 1
                        } else {
                            self.removeFailedURL(link: link)
                            XCTFail("Não foi possível validar a página \(link)")
                            return
                        }
                    } else {
                        self.triesCount[link] = 1
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        XCTAssertTrue((200...299).contains(httpResponse.statusCode),"A página \(link) não está disponível")
                        self.queue.removeAll { $0 == link }
                    }
                    expectation.fulfill()
                }

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
    private func removeFailedURL(link: String) {
        failures.append(link)
        queue.removeAll { $0 == link }
    }
}


