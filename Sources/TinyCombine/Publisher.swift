// MARK: - Publisher

/// Declares that a type can transmit a sequence of values over time.
///
/// A publisher delivers elements to one or more Subscriber instances. The subscriber’s Input and Failure associated types must match the Output and Failure types declared by the publisher. The publisher implements the receive(subscriber:) method to accept a subscriber. After this, the publisher can call the following methods on the subscriber:
///
/// - receive(subscription:): Acknowledges the subscribe request and returns a Subscription instance. The subscriber uses the subscription to demand elements from the publisher and can use it to cancel publishing.
///
/// - receive(_:): Delivers one element from the publisher to the subscriber.
///
/// - receive(completion:): Informs the subscriber that publishing has ended, either normally or with an error.
///
/// Every Publisher must adhere to this contract for downstream subscribers to function correctly.
///
/// Extensions on Publisher define a wide variety of operators that you compose to create sophisticated event-processing chains. Each operator returns a type that implements the Publisher protocol. Most of these types exist as extensions on the Publishers enumeration. For example, the map(_:) operator returns an instance of Publishers.Map.
///
/// Rather than implementing Publisher on your own, you can use one of several types provided by the Combine framework. For example, you can use an AnySubject instance and publish new elements imperatively with its send(_:) method. You can also add the @Published annotation to any property to give it a publisher that returns an instance of Published, which emits an event every time the property’s value changes.
public protocol Publisher {
    
    /// The kind of values published by this publisher.
    associatedtype Output
    
    /// The kind of errors this publisher might publish.
    associatedtype Failure: Error
    
    /// Attaches the specified subscriber to this publisher.
    ///
    /// - Parameter subscriber: The subscriber to attach to this Publisher, after which it can receive values.
    ///
    /// Implementations of Publisher must implement this method.
    ///
    /// The provided implementation of subscribe(_:) calls this method.
    func receive<S>(_ subscriber: S)
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    
}

extension Publisher {
    
    /// Attaches the specified subscriber to this publisher.
    ///
    /// - Parameter subscriber: The subscriber to attach to this publisher. After attaching, the subscriber can start to receive values
    ///
    /// Always call this function instead of receive(subscriber:). Adopters of Publisher must implement receive(subscriber:). The implementation of subscribe(_:) provided by Publisher calls through to receive(subscriber:).
    public func subscribe<S>(_ subscriber: S)
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure { receive(subscriber) }
    
}

extension Publisher {
    
    public func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
        
        .init(self)
        
    }
    
}

// MARK: - Connecting Simple Subscribers

extension Publisher {
    
    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameter receiveCompletion: The closure to execute on receipt of a value. If nil, the sink uses an empty closure.
    /// - Parameter receiveValue: The closure to execute on completion. If nil, the sink uses an empty closure.
    public func sink(
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        receiveValue: @escaping (Output) -> Void
    )
    -> AnyCancellable {
        
        let subscriber = Subscribers.Sink(
            receiveCompletion: receiveCompletion,
            receiveValue: receiveValue
        )
        
        subscribe(subscriber)
        
        return AnyCancellable(subscriber)
        
    }
    
}

// MARK: - Mapping Elements

//extension Publisher {
//
//    /// Transforms all elements from the upstream publisher with a provided closure.
//    ///
//    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
//    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
//    public func map<T>(
//        _ transform: @escaping (Output) -> T
//    )
//    -> Publishers.Map<Self, T> { .init(upstream: self, transform: transform) }
//
//}
