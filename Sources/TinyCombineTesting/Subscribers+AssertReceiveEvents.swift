// MARK: - AssertReceiveEvents

import XCTest
import TinyCombine

extension Subscribers {

    public final class AssertReceiveEvents<Output, Failure>
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
            
            let receiveNewEvent: () -> Void = {
                
                if eventIndexOfCurrentPhase == expectedEvents.count - 1 {
                    
                    didReceiveAllExpectedEvents()
                    
                }
                
                eventIndexOfCurrentPhase += 1
                
            }
            
            let eventOfCurrentPhase: () -> Event<Output, Failure> = {
                
                guard eventIndexOfCurrentPhase < expectedEvents.count else {
                    
                    preconditionFailure("Receive more than expected events.")
                    
                }
                
                return expectedEvents[eventIndexOfCurrentPhase]
                
            }
            
            self.sink = Subscribers.Sink(
                receiveCompletion: { completion in
                    
                    defer { receiveNewEvent() }
                    
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
                    
                    defer { receiveNewEvent() }
                    
                    XCTAssertEqual(
                        .receiveValue(value),
                        eventOfCurrentPhase()
                    )
                    
                }
            )
            
        }
        
    }
        
}

// MARK: - Subscriber

extension Subscribers.AssertReceiveEvents: Subscriber {
    
    public func receive(_ input: Output) -> Subscribers.Demand {
        
        sink.receive(input)
        
    }
    
    public func receive(subscription: Subscription) {
        
        sink.receive(subscription: subscription)
        
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        
        sink.receive(completion: completion)
        
    }
    
}

// MARK: - Cancellable

extension Subscribers.AssertReceiveEvents: Cancellable {
    
    public func cancel() { sink.cancel() }
    
}

