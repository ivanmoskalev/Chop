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
    
    public func onUpdate(_ sub: @escaping (Value) -> Void) -> Task<Value, Error> {
        return on { event in
            switch event {
            case .update(let value):
                sub(value)
            default: break
            }
        }
    }

    /**
     Allows the user to subscribe to `.Failure` event emitted by the task.
     */
    
    public func onFailure(_ sub: @escaping (Error) -> Void) -> Task<Value, Error> {
        return on { event in
            switch event {
            case .failure(let error):
                sub(error)
            default: break
            }
        }
    }

    /**
     Allows the user to subscribe to `.Completion` event emitted by the task.
     */
    
    public func onCompletion(_ sub: @escaping (Void) -> Void) -> Task<Value, Error> {
        return on { event in
            switch event {
            case .completion:
                sub()
            default: break
            }
        }
    }
    
}
