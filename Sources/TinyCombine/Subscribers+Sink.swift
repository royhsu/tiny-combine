// MARK: - Sink

extension Subscribers {
    
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    public final class Sink<Input, Failure> where Failure: Error {
        
        public let receiveCompletion: (Completion<Failure>) -> Void
        
        public let receiveValue: (Input) -> Void
        
        private var subscription: Subscription?
        
        public init(
            receiveCompletion: @escaping (Completion<Failure>) -> Void,
            receiveValue: @escaping (Input) -> Void
        ) {
            
            self.receiveCompletion = receiveCompletion
            
            self.receiveValue = receiveValue
            
        }
        
    }
    
}

// MARK: - Subscriber

extension Subscribers.Sink: Subscriber {
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        
        receiveValue(input)
            
        return .unlimited
        
    }
    
    public func receive(subscription: Subscription) {
        
        self.subscription = subscription
        
        self.subscription?.request(.unlimited)
        
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        
        receiveCompletion(completion)
        
    }
    
}

// MARK: - Cancellable

extension Subscribers.Sink: Cancellable {
    
    public func cancel() { subscription?.cancel() }
    
}
