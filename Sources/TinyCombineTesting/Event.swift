// MARK: - Event

import TinyCombine

/// All possible events for testing Combine behaviors.
public enum Event<Output, Failure> where Failure: Error {
    
    case receiveValue(Output)
    
    case receiveCompletion(Subscribers.Completion<Failure>)
    
}

// MARK: - Equatable

extension Event: Equatable where Output: Equatable, Failure: Equatable {
    
    public static func == (lhs: Event, rhs: Event) -> Bool {
    
        switch (lhs, rhs) {
            
        case (.receiveValue(let lhsValue), .receiveValue(let rhsValue)):
            
            return lhsValue == rhsValue
            
        case (
            .receiveCompletion(let lhsCompletion),
            .receiveCompletion(let rhsCompletion)
        ):
            
            switch (lhsCompletion, rhsCompletion) {
                
            case (.finished, .finished): return true
                
            case (.failure(let lhsError), .failure(let rhsError)):
                
                return lhsError == rhsError
                
            default: return false
                
            }

        default: return false
            
        }
        
    }
    
}
