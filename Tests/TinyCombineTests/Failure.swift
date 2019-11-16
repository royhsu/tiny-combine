/// A convenient error type conforms to Equatable for tes1ting.
struct Failure {
    
    var id: Int
    
}

// MARK: - Error

extension Failure: Error { }

// MARK: - Equatable

extension Failure: Equatable { }
