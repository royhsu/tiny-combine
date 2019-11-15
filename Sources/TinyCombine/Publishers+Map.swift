// MARK: - Map

//import RxSwift
//
//extension Publishers {
//
//    /// A publisher that transforms all elements from the upstream publisher with a provided closure.
//    public struct Map<Upstream, Output> where Upstream: Publisher {
//
//        private let diposeBag = DisposeBag()
//
//        private let outputObservable: Observable<Output>
//
//        init(
//            upstream: Upstream,
//            transform: @escaping (Upstream.Output) -> Output
//        ) {
//
//            self.outputObservable = Observable.create { observer in
//
//                upstream.subscribe(
//                    Subscribers.Sink(
//                        receiveCompletion: { completion in
//
//                            switch completion {
//
//                            case .finished: observer.on(.completed)
//
//                            case let .failure(error): observer.on(.error(error))
//
//                            }
//
//                        },
//                        receiveValue: { output in
//
//                            observer.on(.next(transform(output)))
//
//                        }
//                    )
//                )
//
//                return Disposables.create()
//
//            }
//
//        }
//
//    }
//
//}

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
