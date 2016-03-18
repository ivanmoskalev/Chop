//
// Task+Functional.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

extension Task {

    @warn_unused_result
    public func then<T>(transform: Value -> T) -> Task<T, Error> {
        return then { Task<T, Error>(value: transform($0)) }
    }

    @warn_unused_result
    public func then<T>(transform: Value -> Task<T, Error>) -> Task<T, Error> {
        return Task<T, Error> { handler in
            var task: Task<Value, Error>?
            var producedTask: Task<T, Error>?
            task = self.on { event in
                switch event {
                case .Update(let value):
                    producedTask = transform(value).on { event in
                        handler(event)
                    }
                    producedTask?.start()
                case .Failure(let error):
                    handler(.Failure(error))
                case .Completion:
                    handler(.Completion)
                }
            }
            task?.start()
            return { task = nil; producedTask = nil }
        }
    }

    @warn_unused_result
    public func recover(transform: Error -> Value) -> Task<Value, Error> {
        return Task<Value, Error> { handler in
            var task: Task? = self.on { event in
                switch event {
                case .Update(let value):
                    handler(.Update(value))
                case .Failure(let error):
                    handler(.Update(transform(error)))
                case .Completion:
                    handler(.Completion)
                }
            }
            task?.start()
            return { task = nil }
        }
    }
    
}
