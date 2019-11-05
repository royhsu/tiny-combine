// MARK: - AnySubscriber

/// A type-erasing subscriber.
///Use AnyPublisher to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
/// Use an AnySubscriber to wrap an existing subscriber whose details you don’t want to expose. You can also use AnySubscriber to create a custom subscriber by providing closures for the methods defined in Subscriber, rather than implementing Subscriber directly.
public struct AnySubscriber<Input, Failure> where Failure: Error {
    
    private let _receiveInput: (Input) -> Subscribers.Demand
    
    private let _receiveSubscription: (Subscription) -> Void
    
    private let _receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    
    public init<S>(_ subscriber: S)
    where
        S: Subscriber,
        S.Input == Input,
        S.Failure == Failure {
            
        self._receiveInput = subscriber.receive
    
        self._receiveSubscription = subscriber.receive
            
        self._receiveCompletion = subscriber.receive
            
    }
    
}

// MARK: - Subscriber

extension AnySubscriber: Subscriber {
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        
        _receiveInput(input)
        
    }
    
    public func receive(subscription: Subscription) {
        
        _receiveSubscription(subscription)
        
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        
        _receiveCompletion(completion)
        
    }
    
}
