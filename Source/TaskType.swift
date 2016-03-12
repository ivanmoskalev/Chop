//
// TaskType.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
// 
// This software may be modified and distributed under the terms of the MIT license. 
// See the LICENSE file for details.
//

import Foundation

/// A protocol defining the basic interface of an asynchronous task.
public protocol TaskType {

    /// Starts the execution of a task.
    func start()

    /// Returns whether the task is finished.
    func isFinished() -> Bool
}

internal protocol CompletionSubscribable {
    func onCompletion(sub: Void -> Void)
}
