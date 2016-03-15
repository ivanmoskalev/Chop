//
// Task.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

import Foundation

/**
 The events that can be dispatched by the task.
 */
public enum Event<V, E> {
    /// An update to yielded value. This can be a final or a non-final update.
    case Update(value: V)
    /// A faiulre. Automatically triggers `.Completion` after being dispatched.
    case Failure(error: E)
    /// The completion – it means that the task is finished and can be disposed of.
    case Completion
}

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


    //////////////////////////////////////////////////
    // Init / Deinit

    /**
     Creates a `Task` with a given closure.

     - parameter operation: A closure that contains the work to be done.

     - returns: An instance of `Task` ready for firing.
     */
    public init(operation: OperationType) {
        self.operation = operation
    }

    /**
     Creates a `Task` that provides a value then completes.

     - parameter value: The value that will be pushed to task's observers.

     - returns: An instance of `Task`.
     */
    public convenience init(value: Value) {
        self.init {
            $0(.Update(value: value)); $0(.Completion); return {}
        }
    }

    /**
     Creates a `Task` that completes with an error.

     - parameter value: The error that will be pushed to task's observers.

     - returns: An instance of `Task`.
     */
    public convenience init(error: Error) {
        self.init {
            $0(.Failure(error: error)); return {}
        }
    }

    deinit {
        // Call the user-provided dispose closure that frees the associated resources.
        disposeHandler?()
    }


    //////////////////////////////////////////////////
    // Core

    /**
     Allows the user to subscribe to the events that are pushed by the task.

     - parameter sub: The closure in which task handling should take place.

     - returns: The same task – to facilitate chaining.
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
        guard disposeHandler == nil else {
            return
        }
        disposeHandler = operation { [weak self] in
            self?.propagate($0)
        }
    }

    /**
     Inherited from `TaskType`.

     - returns: Whether the task is finished (`.Completion` event has been pushed)
     */
    public func isFinished() -> Bool {
        return finished
    }

    /**
     Propagates the event to subscribers, can fire side-effects.

     - parameter event: The event which should be handled.
     */
    private func propagate(event: EventType) {
        markFinishedIfCompletion(event)
        for sub in self.subscriptions {
            sub(event)
        }
        propagateCompletionIfFailure(event)
    }

    private func propagateCompletionIfFailure(event: EventType) {
        switch event {
        case .Failure(_):
            self.propagate(.Completion)
        default:
            break
        }
    }

    private func markFinishedIfCompletion(event: EventType) {
        switch event {
        case .Completion:
            self.finished = true
        default:
            break
        }
    }


    //////////////////////////////////////////////////
    // Convenience

    /**
     Allows the user to subscribe to the `.Update` events that are pushed by the task.

     - parameter sub: The closure in which `.Update` event handling can take place.

     - returns: The same task – to facilitate chaining.
    */
    @warn_unused_result
    public func onUpdate(sub: Value -> Void) -> Task<Value, Error> {
        return on { event in
            switch event {
            case .Update(let value):
                sub(value)
            default: break
            }
        }
    }

    /**
     Allows the user to subscribe to the `.Failure` event that is pushed by the task.

     - parameter sub: The closure in which `.Failure` event handling can take place.

     - returns: The same task – to facilitate chaining.
     */
    @warn_unused_result
    public func onFailure(sub: Error -> Void) -> Task<Value, Error> {
        return on { event in
            switch event {
            case .Failure(let error):
                sub(error)
            default: break
            }
        }
    }

    /**
     Allows the user to subscribe to the `.Completion` event that is pushed by the task.

     - parameter sub: The closure in which `.Completion` event handling can take place.

     - returns: The same task – to facilitate chaining.
     */
    @warn_unused_result
    public func onCompletion(sub: Void -> Void) -> Task<Value, Error> {
        return on { event in
            switch event {
            case .Completion:
                sub()
            default: break
            }
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


//////////////////////////////////////////////////
// Functional

extension Task {

    @warn_unused_result
    public func map<T>(transform: Value -> T) -> Task<T, Error> {
        return Task<T, Error> { handler in
            var task: Task? = self.on { event in
                switch event {
                case .Update(let value):
                    handler(.Update(value: transform(value)))
                case .Failure(let error):
                    handler(.Failure(error: error))
                case .Completion:
                    handler(.Completion)
                }
            }
            task?.start()
            return { task = nil }
        }
    }

    @warn_unused_result
    public func recover(transform: Error -> Value) -> Task<Value, Error> {
        return Task<Value, Error> { handler in
            var task: Task? = self.on { event in
                switch event {
                case .Update(let value):
                    handler(.Update(value: value))
                case .Failure(let error):
                    handler(.Update(value: transform(error)))
                case .Completion:
                    handler(.Completion)
                }
            }
            task?.start()
            return { task = nil }
        }
    }

}
