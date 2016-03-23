//
// Task.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

public final class Task<Value, Error> : TaskType {

    /// The type of Event that can occur.
    public typealias EventType = Event<Value, Error>

    /// The type of closure that disposes of any resources for task.
    public typealias DisposeType = Void -> Void

    /// The type of closure that performs the operation.
    public typealias OperationType = (EventType -> Void) -> DisposeType

    /// The type of closure that describes the subscription.
    public typealias SubscriptionType = EventType -> Void

    /// The operation that an instance of task wraps.
    private let operation: OperationType

    /// An array of subscription closures for the result of operation.
    private var subscriptions: [SubscriptionType] = []

    /// The handler that disposes of the task when it is not needed anymore.
    private var disposeHandler: DisposeType?

    /// Whether the task is finished.
    private var finished: Bool = false

    /// The lock that guards `emit`s.
    private var emitLock = NSRecursiveLock()

    //////////////////////////////////////////////////
    // Init / Deinit

    /**
     Creates a `Task` with a given closure.
     */
    public init(operation: OperationType) {
        self.operation = operation
    }

    /**
     Creates a `Task` that emits a value and completes.
     */
    public convenience init(value: Value) {
        self.init {
            $0(.Update(value)); $0(.Completion); return {}
        }
    }

    /**
     Creates a `Task` that completes with an error.
     */
    public convenience init(error: Error) {
        self.init {
            $0(.Failure(error)); return {}
        }
    }

    /**
     By design, `deinit` cancels the task.
     */
    deinit {
        cancel()
    }


    //////////////////////////////////////////////////
    // Public

    /**
     Allows the user to subscribe to all events emitted by the task.
     */
    @warn_unused_result
    public func on(sub: EventType -> Void) -> Task<Value, Error> {
        subscriptions.append(sub)
        return self
    }

    /**
     Starts the task if it is not started yet.
     */
    public func start() {
        guard disposeHandler == nil else { return }
        disposeHandler = operation { [weak self] in
            self?.emit($0)
        }
    }

    /**
     Silently cancels the task. No events are emitted. 
     `disposeHandler` is called so that resources can be freed.
     */
    public func cancel() {
        finished = true
        subscriptions.removeAll()
        disposeHandler?()
        disposeHandler = nil
    }

    /**
     Returns `true` if task is finished (`.Completion` event has been pushed.)
     */
    public func isFinished() -> Bool {
        return finished
    }


    //////////////////////////////////////////////////
    // Private

    /**
     Emits `event` to subscribers, can fire side-effects.
     */
    private func emit(event: EventType) {
        emitLock.lock()
        completeIfFailure(event)
        for sub in self.subscriptions {
            sub(event)
        }
        finishIfCompletion(event)
        emitLock.unlock()
    }

    /**
     Additionaly emits a `.Completion` task if `event` is `.Failure`.
     */
    private func completeIfFailure(event: EventType) {
        switch event {
        case .Failure(_):
            emit(.Completion)
        default:
            break
        }
    }

    /**
     Sets `finished` to `true` if `event` is `.Completion`.
     */
    private func finishIfCompletion(event: EventType) {
        switch event {
        case .Completion:
            finished = true
        default:
            break
        }
    }

}


//////////////////////////////////////////////////
// Internal

extension Task : CompletionSubscribable {

    internal func onCompletion(sub: Void -> Void) {
        let _ : Task<Value, Error> = self.onCompletion(sub)
    }

}
