// MARK: - Map

extension Publishers {

    /// A publisher that transforms all elements from the upstream publisher with a provided closure.
//    public struct Map<Upstream, Output> where Upstream: Publisher {
//
//        private let future: Future<Output, Upstream.Failure>
//
//        init(
//            upstream: Upstream,
//            transform: @escaping (Upstream.Output) -> Output
//        ) {
//
//            #warning("TODO: [Priority: high] we can't use future becuase it can't observe multiple values.")
//            self.future = Future { promise in
//
//                upstream.receive(
//                    Subscribers.Sink(
//                        receiveCompletion: { completion in
//
//                            switch completion {
//                                
//                            case .finished: break
//
//                            case let .failure(error): promise(.failure(error))
//
//                            }
//
//                        },
//                        receiveValue: { value in
//
//                            promise(.success(transform(value)))
//
//                        }
//                    )
//                )
//
//            }
//
//        }
//
//    }

}

// MARK: - Publisher

//extension Publishers.Map: Publisher {
//
//    public typealias Failure = Upstream.Failure
//
//    public func receive<S>(_ subscriber: S)
//    where
//        S : Subscriber,
//        S.Input == Output,
//        S.Failure == Failure {
//
//        outputObservable
//            .subscribe { event in
//
//                switch event {
//
//                case let .next(output): _ = subscriber.receive(output)
//
//                case let .error(error):
//
//                    subscriber.receive(completion: .failure(error as! Failure))
//
//                case .completed: subscriber.receive(completion: .finished)
//
//                }
//
//            }
//            .disposed(by: diposeBag)
//
//    }
//
//}
