// MARK: - Demand

extension Subscribers {
    
    /// A requested number of items, sent to a publisher from a subscriber through the subscription.
    public struct Demand {
        
        /// The number of requested values.
        ///
        /// The value is nil if the demand is unlimited.
        public private(set) var max: Int?
        
        init(max: Int? = nil) {
            
            self.max = max.map { value in
                
                precondition(value >= 0)
                
                return value
                
            }
            
        }
        
    }
    
}

// MARK: - Equatable

extension Subscribers.Demand: Equatable { }

extension Subscribers.Demand: Comparable {
    
    public static func < (
        lhs: Subscribers.Demand,
        rhs: Subscribers.Demand
    )
    -> Bool {
        
        if let lhsMax = lhs.max {
            
            if let rhsMax = rhs.max { return lhsMax < rhsMax }
            else { /* rhs is unlimited. */ return true }
            
        }
        else { // lhs is unlimited.
            
            if let _ = rhs.max { return false }
            else { /* rhs is unlimited. */ return true }
            
        }
        
    }
    
}

extension Subscribers.Demand {

    /// Creates a demand for the given maximum number of elements.
    ///
    /// - Parameter value: The maximum number of elements. Providing a negative value for this parameter results in a fatal error.
    ///
    /// The publisher is free to send fewer than the requested maximum number of elements.
    public static func max(_ value: Int) -> Self { Self(max: value) }
    
    /// A request for as many values as the publisher can produce.
    public static let unlimited = Self(max: nil)
    
    /// A request for no elements from the publisher.
    ///
    /// This is equivalent to Demand.max(0).
    public static let none = Self(max: 0)
    
}
