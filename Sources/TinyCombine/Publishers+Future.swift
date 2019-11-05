// MARK: - Future

import RxSwift

extension Publishers {
    
    /// A publisher that eventually produces a single value and then finishes or fails.
    public final class Future<Output, Failure> where Failure: Error {
        
        private let diposeBag = DisposeBag()
        
        private let outputObservable: Observable<Output>
        
        /// Creates a publisher that invokes a promise closure when the publisher emits an element.
        ///
        /// - Parameter attempToFulfill: A Future.Promise that the publisher invokes when the publisher emits an element or terminates with an error.
        public init(_ attempToFulfill: @escaping Promise) {
            
            var isFinished = false
            
            outputObservable = Observable.create { observer in
                
                attempToFulfill { result in
                    
                    precondition(!isFinished, "A promise can only be fulfilled exactly once.")
                    
                    isFinished = true
                    
                    do {
                        
                        try observer.on(.next(result.get()))
                        
                        observer.on(.completed)
                        
                    }
                    catch { observer.on(.error(error)) }
                        
                }
                
                return Disposables.create()

            }
            
        }
        
    }
    
}

// MARK: - Publisher

extension Publishers.Future: Publisher {
    
    public func receive<S>(_ subscriber: S)
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        
        outputObservable
            .subscribe { event in

                switch event {
                    
                case let .next(output): _ = subscriber.receive(output)
                    
                case let .error(error):
                    
                    subscriber.receive(completion: .failure(error as! Failure))
                    
                case .completed: subscriber.receive(completion: .finished)
                    
                }
                
            }
            .disposed(by: diposeBag)
            
    }
    
}

// MARK: - Promise

extension Publishers.Future {
    
    /// A type that represents a closure to invoke in the future, when an element or error is available.
    public typealias Promise = (@escaping (Result<Output, Failure>) -> Void) -> Void
    
}
