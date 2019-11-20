// MARK: - AssertReceiveEvents

import TinyCombine

extension Publisher where Output: Equatable, Failure: Equatable {
    
    public func assertReceive(
        expectedEvents: [Event<Output, Failure>],
        didReceiveAllExpectedEvents: @escaping () -> Void
    )
    -> AnyCancellable {
        
        let subscriber = Subscribers.AssertReceiveEvents(
            expectedEvents: expectedEvents,
            didReceiveAllExpectedEvents: didReceiveAllExpectedEvents
        )
        
        subscribe(subscriber)
        
        return AnyCancellable(subscriber)
        
    }
    
}
