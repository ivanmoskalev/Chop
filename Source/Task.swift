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

public enum Event<V, E> {
    case Update(value: V)
    case Failure(error: E)
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


    //////////////////////////////////////////////////
    // Init / Deinit

    public init(operation: OperationType) {
        self.operation = operation
    }

    public convenience init(value: Value) {
        self.init {
            $0(.Update(value: value)); $0(.Completion); return {}
        }
    }

    public convenience init(error: Error) {
        self.init {
            $0(.Failure(error: error)); $0(.Completion); return {}
        }
    }

    deinit {
        disposeHandler?()
    }


    //////////////////////////////////////////////////
    // Core

    @warn_unused_result
    public func on(sub: EventType -> Void) -> Task<Value, Error> {
        subscriptions.append(sub)
        return self
    }

    public func start() {
        guard disposeHandler == nil else {
            return
        }
        disposeHandler = operation { [weak self] in
            self?.propagate($0)
        }
    }

    private func propagate(event: EventType) {
        for sub in self.subscriptions {
            sub(event)
        }

        switch event {
        case .Failure(_):
            self.propagate(.Completion)
        default:
            break;
        }
    }


    //////////////////////////////////////////////////
    // Convenience

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
