// MARK: - AnyPublisher

/// A type-erasing publisher.
///
/// Use AnyPublisher to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
public struct AnyPublisher<Output, Failure> where Failure: Error {
    
    private let _receive: (AnySubscriber<Output, Failure>) -> Void
    
    public init<P>(_ publisher: P)
    where
        P: Publisher,
        P.Output == Output,
        P.Failure == Failure {
        
        self._receive = { publisher.receive($0) }
        
    }
    
}

// MARK: - Publisher

extension AnyPublisher: Publisher {
    
    public func receive<S>(_ subscriber: S)
    where
        S: Subscriber,
        S.Failure == Failure,
        S.Input == Output {
        
        _receive(AnySubscriber(subscriber))
            
    }
    
}
