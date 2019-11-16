// MARK: - FutureTests

import XCTest

@testable import TinyCombine

final class FutureTests: XCTestCase {

    func testReceiveValueAndFinishedCompletion() {
        
        var events: [Event<Int, Failure>] = []
        
        let expectedEvents: [Event<Int, Failure>] = [
            .receiveValue(1),
            .receiveCompletion(.finished),
        ]
        
        let didReceiveEvent = expectation(description: "Did receive event.")
        
        didReceiveEvent.expectedFulfillmentCount = expectedEvents.count
        
        let stream = Future<Int, Never> { promise in
            
            DispatchQueue.global(qos: .background).async {

                promise(.success(1))
                
            }
            
        }
            .sink(
                receiveCompletion: { completion in
                    
                    switch completion {
                        
                    case .finished:
                        
                        defer { didReceiveEvent.fulfill() }
                        
                        events.append(.receiveCompletion(.finished))
                    
                        XCTAssertEqual(
                            events,
                            [
                                .receiveValue(1),
                                .receiveCompletion(.finished)
                            ]
                        )
                        
                    case let .failure(error): XCTFail("\(error)")
                    
                    }
                    
                },
                receiveValue: { value in
                    
                    defer { didReceiveEvent.fulfill() }
                    
                    events.append(.receiveValue(value))
                    
                    XCTAssertEqual(events, [ .receiveValue(1), ])
                    
                }
            )
        
        waitForExpectations(timeout: 10.0)
        
    }
    
    func testReceiveFailureCompletion() {
        
        var events: [Event<Int, Failure>] = []
        
        let expectedEvents: [Event<Int, Failure>] = [
            .receiveCompletion(.failure(Failure(id: 1))),
        ]
        
        let didReceiveEvent = expectation(description: "Did receive event.")
        
        didReceiveEvent.expectedFulfillmentCount = expectedEvents.count
        
        let stream = Future<Int, Failure> { promise in
            
            DispatchQueue.global(qos: .background).async {

                promise(.failure(Failure(id: 1)))
                
            }
            
        }
            .sink(
                receiveCompletion: { completion in
                    
                    switch completion {
                        
                    case .finished: XCTFail("Should end up with failure.")
                        
                    case let .failure(error):
                        
                        defer { didReceiveEvent.fulfill() }
                    
                        XCTAssertEqual(error, Failure(id: 1))
                        
                    }
                    
                },
                receiveValue: { _ in XCTFail("Shouldn't receive any value.") }
            )
        
        waitForExpectations(timeout: 10.0)
        
    }
    
}

extension FutureTests {
    
    static var allTests = [
        ("testReceiveFailureCompletion", testReceiveFailureCompletion),
        ("testReceiveValueAndFinishedCompletion", testReceiveValueAndFinishedCompletion),
    ]
    
}
