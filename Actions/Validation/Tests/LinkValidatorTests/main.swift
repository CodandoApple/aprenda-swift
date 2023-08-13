import Foundation
import XCTest
@testable import LinkValidator

class LinkValidatorTest: XCTestCase {
    
    let linkValidator = LinkValidator(urlSession: .init(configuration: .ephemeral))

    func test_repositoryURL_isValid() async throws {
        
        let expectaction = expectation(description: "Repository URL is available")
        
        var link = Link(name: "Aprenda Swift", url: "https://github.com/CodandoApple/aprenda-swift.git")
        
        await linkValidator.validateLink(&link)
        
        if link.isValid {
            expectaction.fulfill()
        }
        
        await fulfillment(of: [expectaction], timeout: 10.0)
    }
    
    func test_malformedURL_isNotValid() async throws {
        let expectaction = expectation(description: "Misformatted URL is not valid")
        
        var link = Link(name: "Malformed URL", url: "https://-github.com/CodandoApple/aprenda-swift.git")
        
        await linkValidator.validateLink(&link)
        
        if !link.isValid {
            expectaction.fulfill()
        }
        
        await fulfillment(of: [expectaction], timeout: 10.0)
    }

    func test_extractLinksFromText_shouldSucceed() throws {
        let file = try XCTUnwrap(Bundle.module.path(forResource: "extractLinksFromText", ofType: "md"))
        let text = try String(contentsOfFile: file)
        
        let links = linkValidator.extractLinksFromText(text)
        
        XCTAssertGreaterThan(links.count, 0)
        
        let aprendaSwiftLink = Link(name: "Aprenda Swift", url: "https://github.com/CodandoApple/aprenda-swift.git")
        
        let link = links[0]
        
        XCTAssertEqual(link, aprendaSwiftLink)
    }
    
    func test_validateLinksFromText_withValidLinks_shouldReturnEmptyCollection() async throws {
        let file = try XCTUnwrap(Bundle.module.path(forResource: "validLinks", ofType: "md"))
        let text = try String(contentsOfFile: file)
        
        let expectation = expectation(description: "All links for validLinks.md are valid")
        
        let invalidLinks = await linkValidator.validateLinksForText(text)
        
        if invalidLinks.isEmpty {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func test_validateLinksFromText_withInvalidLinks_shouldReturnItems() async throws {
        let file = try XCTUnwrap(Bundle.module.path(forResource: "invalidLinks", ofType: "md"))
        let text = try String(contentsOfFile: file)
        
        let expectation = expectation(description: "All links for invalidLinks.md are invalid")
        
        let invalidLinks = await linkValidator.validateLinksForText(text)
        
        if invalidLinks.count == 2 {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func test_validateLinksFromText_withIgnoredLinks_shouldReturnEmptyCollection() async throws {
        let file = try XCTUnwrap(Bundle.module.path(forResource: "ignoredLinks", ofType: "md"))
        let text = try String(contentsOfFile: file)
        
        let expectation = expectation(description: "All links for ignoredLinks.md are valid")
        
        let invalidLinks = await linkValidator.validateLinksForText(text)
        
        if invalidLinks.isEmpty {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}


