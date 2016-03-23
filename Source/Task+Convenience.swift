//
// Task+Convenience.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

extension Task {

    /**
     Allows the user to subscribe to `.Update` events emitted by the task.
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
     Allows the user to subscribe to `.Failure` event emitted by the task.
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
     Allows the user to subscribe to `.Completion` event emitted by the task.
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
