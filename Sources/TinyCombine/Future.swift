// MARK: - Future

import Foundation

/// A publisher that eventually produces a single value and then finishes or fails.
public final class Future<Output, Failure> where Failure: Error {
    
    private let attempToFulfill: (@escaping Promise) -> Void
    
    private let resultLock = NSLock()
    
    private(set) var result: Result<Output, Failure>?
    
    public init(_ attempToFulfill: @escaping (@escaping Promise) -> Void) {
        
        self.attempToFulfill = attempToFulfill
        
    }
    
    /// Resolve the promise in a thread-safe manner.
    /// Note that the result will be cached when it completes. That means the current future will never
    /// attempt to fulfill more than once.
    private func resolve(promise: @escaping Promise) {
        
        resultLock.lock()
        
        if let result = result {
            
            resultLock.unlock()
            
            promise(result)
            
        }
        else {

            resultLock.unlock()
            
            attempToFulfill { result in
                
                self.resultLock.lock()
                
                self.result = result
                
                self.resultLock.unlock()
                
                promise(result)
                
            }
            
        }
        
    }
    
}

extension Future {
    
    private final class Connection: Subscription {

        private let queue = OperationQueue()
        
        private enum ResolveState {
            
            case pending, resolving, resolved
            
        }
        
        private let resolveStateLock = NSLock()
        
        private var resolveState = ResolveState.pending
        
        private let resolve: (@escaping Promise) -> Void
        
        private let subscriber: AnySubscriber<Output, Failure>
    
        init(
            resolve: @escaping (@escaping Promise) -> Void,
            subscriber: AnySubscriber<Output, Failure>
        ) {
            
            self.resolve = resolve
            
            self.subscriber = subscriber
            
        }

        // No matter what demand the subsciber needs, the future only
        // produces one result.
        func request(_ demand: Subscribers.Demand) {

            switch demand {
                
            case .none: break
                
            default:
                
                resolveStateLock.lock()
                
                switch resolveState {
                    
                case .pending:
                    
                    resolveState = .resolving
                    
                    resolveStateLock.unlock()
                    
                    queue.addOperation {
                        
                        self.resolve { result in

                            self.resolveStateLock.lock()
                            
                            self.resolveState = .resolved
                            
                            self.resolveStateLock.unlock()
                            
                            self.notifySubscriber(result)
                            
                        }
                        
                    }
                    
                case .resolving, .resolved: resolveStateLock.unlock()
                    
                }
                
            }
            
        }

        private func notifySubscriber(_ result: Result<Output, Failure>) {
            
            do {
                
                let value = try result.get()
                
                _ = subscriber.receive(value)
                
                subscriber.receive(completion: .finished)
                
            }
            catch {
                
                subscriber.receive(completion: .failure(error as! Failure))
                
            }
            
        }
            
        func cancel() { queue.cancelAllOperations() }

    }
    
}

// MARK: - Publisher

extension Future: Publisher {

    public func receive<S>(_ subscriber: S)
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {

        subscriber.receive(
            subscription: Connection(
                resolve: resolve,
                subscriber: AnySubscriber(subscriber)
            )
        )
            
    }

}

// MARK: - Promise

extension Future {
    
    /// A type that represents a closure to invoke in the future, when an element or error is available.
    public typealias Promise = (Result<Output, Failure>) -> Void
    
}
