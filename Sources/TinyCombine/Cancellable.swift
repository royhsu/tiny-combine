// MARK: - Cancellable

/// A protocol indicating that an activity or action supports cancellation.
///
/// Calling cancel() frees up any allocated resources. It also stops side effects such as timers, network access, or disk I/O.
public protocol Cancellable {
    
    /// Cancel the activity.
    func cancel()
    
}
