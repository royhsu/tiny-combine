// MARK: - Subscription

/// A protocol representing the connection of a subscriber to a publisher.
public protocol Subscription: Cancellable {
    
    func request(_ demand: Subscribers.Demand)
    
}
