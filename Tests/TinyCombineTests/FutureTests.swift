// MARK: - FutureTests

import XCTest

@testable import TinyCombine

final class FutureTests: XCTestCase {

    func testReceiveValueAndFinishedCompletion() {
        
        let didReceiveAllEvents = expectation(description: "Did receive all events.")
        
        let stream = Future<Int, Never> { promise in
            
            DispatchQueue.global(qos: .background).async {

                promise(.success(1))
                
            }
            
        }
            .assertReceive(
                expectedEvents: [
                    .receiveValue(1),
                    .receiveCompletion(.finished),
                ],
                didReceiveAllExpectedEvents: didReceiveAllEvents.fulfill
            )
        
        waitForExpectations(timeout: 10.0)
        
    }
    
    func testReceiveFailureCompletion() {
        
        let didReceiveAllEvents = expectation(description: "Did receive all events.")
        
        let stream = Future<Int, Failure> { promise in
            
            DispatchQueue.global(qos: .background).async {

                promise(.failure(Failure(id: 1)))
                
            }
            
        }
            .assertReceive(
                expectedEvents: [
                    .receiveCompletion(.failure(Failure(id: 1))),
                ],
                didReceiveAllExpectedEvents: didReceiveAllEvents.fulfill
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
