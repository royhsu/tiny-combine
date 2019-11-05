// MARK: - AnyCancellable
 
/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the Subscription object to request items.
///
/// An AnyCancellable instance automatically calls cancel() when deinitialized.
public final class AnyCancellable {
    
    private let _cancel: () -> Void
    
    /// Initializes the cancellable object with the given cancel-time closure.
    public init(_ cancel: @escaping () -> Void) { self._cancel = cancel }
    
    deinit { cancel() }
    
}

extension AnyCancellable {
    
    public convenience init<C>(_ canceller: C) where C: Cancellable {
        
        self.init(canceller.cancel)
        
    }
    
}

// MARK: - Cancellable

extension AnyCancellable: Cancellable {
    
    public func cancel() { _cancel() }
    
}
