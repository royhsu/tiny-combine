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

final class AssertReceiveEvents<Output, Failure>
where
    Output: Equatable,
    Failure: Error,
    Failure: Equatable {
    
    private let sink: Subscribers.Sink<Output, Failure>
    
    init(
        expectedEvents: [Event<Output, Failure>],
        didReceiveAllExpectedEvents: @escaping () -> Void
    ) {
        
        var eventIndexOfCurrentPhase = 0
        
        let eventOfCurrentPhase: () -> Event<Output, Failure> = {
            
            guard eventIndexOfCurrentPhase < expectedEvents.count else {
                
                preconditionFailure("Receive more than expected events.")
                
            }
            
            return expectedEvents[eventIndexOfCurrentPhase]
            
        }
        
        let checkIfAllEventsReceived: () -> Void = {
            
            guard
                eventIndexOfCurrentPhase == expectedEvents.count - 1
            else { return }
                
            didReceiveAllExpectedEvents()
            
        }
        
        self.sink = Subscribers.Sink(
            receiveCompletion: { completion in
                
                defer {
                    
                    checkIfAllEventsReceived()
                    
                    eventIndexOfCurrentPhase += 1
                    
                }
                
                switch completion {
                    
                case .finished:
                    
                    XCTAssertEqual(
                        .receiveCompletion(.finished),
                        eventOfCurrentPhase()
                    )
                    
                case let .failure(error):
                    
                    XCTAssertEqual(
                        .receiveCompletion(.failure(error)),
                        eventOfCurrentPhase()
                    )
                    
                }
                
            },
            receiveValue: { value in
                
                defer {
                    
                    checkIfAllEventsReceived()
                    
                    eventIndexOfCurrentPhase += 1
                    
                }
                
                XCTAssertEqual(
                    .receiveValue(value),
                    eventOfCurrentPhase()
                )
                
            }
        )
        
    }
    
}

extension AssertReceiveEvents: Subscriber {
    
    func receive(_ input: Output) -> Subscribers.Demand {
        
        sink.receive(input)
        
    }
    
    func receive(subscription: Subscription) {
        
        sink.receive(subscription: subscription)
        
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        
        sink.receive(completion: completion)
        
    }
    
}

extension AssertReceiveEvents: Cancellable {
    
    func cancel() { sink.cancel() }
    
}

extension Publisher where Output: Equatable, Failure: Equatable {
    
    func assertReceive(
        expectedEvents: [Event<Output, Failure>],
        didReceiveAllExpectedEvents: @escaping () -> Void
    )
    -> AnyCancellable {
        
        let subscriber = AssertReceiveEvents(
            expectedEvents: expectedEvents,
            didReceiveAllExpectedEvents: didReceiveAllExpectedEvents
        )
        
        subscribe(subscriber)
        
        return AnyCancellable(subscriber)
        
    }
    
}

extension FutureTests {
    
    static var allTests = [
        ("testReceiveFailureCompletion", testReceiveFailureCompletion),
        ("testReceiveValueAndFinishedCompletion", testReceiveValueAndFinishedCompletion),
    ]
    
}
