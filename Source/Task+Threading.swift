//
// Task+Threading.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

import Foundation

extension Task {

    @warn_unused_result
    public func switchTo(scheduler: Scheduler) -> Task<Value, Error> {
        return Task<Value, Error> { handler in
            var task: Task<Value, Error>? = self.on { event in
                scheduler.perform {
                    handler(event)
                }
            }
            task?.start()
            return { task = nil }
        }
    }

}
