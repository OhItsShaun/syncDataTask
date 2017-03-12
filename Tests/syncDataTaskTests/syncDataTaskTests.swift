import XCTest
@testable import syncDataTask

class syncDataTaskTests: XCTestCase {
    
    func testTimeout() {
        do {
            let url = URL(string: "https://www.swift.org/")!
            let request = URLRequest(url: url, timeoutInterval: 0.01)
            
            _ = try URLSession.shared.syncDataTask(with: request)
            
            XCTFail("Expected timeout. Request suceeded.")
        }
        catch let error as URLError {
            switch error.code {
            case .timedOut:
                return
            default:
                XCTFail("Expected timeout. Unexpected error thrown: \(error)")
            }
        }
        catch let error {
            XCTFail("Expected timeout. Unexpected error thrown: \(error)")
        }
    }


    static var allTests : [(String, (syncDataTaskTests) -> () throws -> Void)] {
        return [
            ("testTimeout", testTimeout),
        ]
    }
    
}
