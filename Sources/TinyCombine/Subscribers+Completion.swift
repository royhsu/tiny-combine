// MARK: - Completion

extension Subscribers {
    
    /// A signal that a publisher doesn’t produce additional elements, either due to normal completion or an error.
    public enum Completion<Failure> where Failure: Error {
        
        /// The publisher finished normally.
        case finished
        
        /// The publisher stopped publishing due to the indicated error.
        case failure(Failure)
        
    }
    
}

// MARK: - Equatable

extension Subscribers.Completion: Equatable where Failure: Equatable { }
