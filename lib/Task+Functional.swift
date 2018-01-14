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

  /**
   Returns a `Task` with values that are produced by applying `transform` to every yielded `.Update` event.
   `transform` must return a transformed value.
   */

  public func then<T>(_ transform: @escaping (Value) -> T) -> Task<T, Error> {
    return then { Task<T, Error>(value: transform($0)) }
  }

  /**
   Returns a `Task` with values that are produced by applying `transform` to every yielded `.Update` event.
   `transform` must return an instance of `Task`.
   */

  public func then<T>(_ transform: @escaping (Value) -> Task<T, Error>) -> Task<T, Error> {
    return Task<T, Error> { handler in
      var task: Task<Value, Error>?
      var producedTask: Task<T, Error>?
      task = self.on { event in
        switch event {
        case let .update(value):
          producedTask = transform(value).on { event in
            handler(event)
          }
          producedTask?.start()
        case let .failure(error):
          handler(.failure(error))
        case .completion:
          handler(.completion)
        }
      }
      task?.start()
      return { task = nil; producedTask = nil }
    }
  }

  /**
   Returns a `Task` with values that are produced by applying `transform` to every yielded `.Failure` event.
   `transform` must return a value.
   */

  public func recover(_ transform: @escaping (Error) -> Value) -> Task<Value, Error> {
    return recover { Task<Value, Error>(value: transform($0)) }
  }

  /**
   Returns a `Task` with values that are produced by applying `transform` to every yielded `.Failure` event.
   `transform` must return an instance of `Task`.
   */

  public func recover(_ transform: @escaping (Error) -> Task<Value, Error>) -> Task<Value, Error> {
    return Task<Value, Error> { handler in
      var task: Task<Value, Error>?
      var producedTask: Task<Value, Error>?

      task = self.on { event in
        switch event {
        case let .update(value):
          handler(.update(value))
        case let .failure(error):
          producedTask = transform(error).on { event in
            handler(event)
          }
          producedTask?.start()
        case .completion:
          handler(.completion)
        }
      }
      task?.start()
      return { task = nil; producedTask = nil }
    }
  }
}
