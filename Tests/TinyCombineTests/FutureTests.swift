// MARK: - FutureTests

import XCTest

@testable import TinyCombine

final class FutureTests: XCTestCase {

    enum Event<Output, Failure>: Equatable
    where
        Output: Equatable,
        Failure: Error,
        Failure: Equatable {
        
        case receiveValue(Output)
        
        case receiveCompletion(Subscribers.Completion<Failure>)
        
        static func == (lhs: Event, rhs: Event) -> Bool {
        
            switch (lhs, rhs) {
                
            case (.receiveValue(let lhsValue), .receiveValue(let rhsValue)):
                
                return lhsValue == rhsValue
                
            case (
                .receiveCompletion(let lhsCompletion),
                .receiveCompletion(let rhsCompletion)
            ):
                
                switch (lhsCompletion, rhsCompletion) {
                    
                case (.finished, .finished): return true
                    
                case (.failure(let lhsError), .failure(let rhsError)):
                    
                    return lhsError == rhsError
                    
                default: return false
                    
                }
    
            default: return false
                
            }
            
        }
        
    }
    
    func testReceiveValueAndFinishedCompletion() {
        
        var events: [Event<Int, Never>] = []
        
        let expectedEvents: [Event<Int, Never>] = [
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
    
}

extension FutureTests {
    
    static var allTests = [
        ("testReceiveValueAndFinishedCompletion", testReceiveValueAndFinishedCompletion),
    ]
    
}
