//
// TaskGroup.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

import Foundation

public final class TaskGroup : TaskType {

    /// A dictionary of tasks retrievable by task identifiers.
    private(set) var tasks = [String : TaskType]()

    /// Whether the tasks should start immediately upon being added.
    public let startsImmediately: Bool


    //////////////////////////////////////////////////
    // Init

    /// Creates a TaskGroup.
    public init(startsImmediately: Bool = true) {
        self.startsImmediately = startsImmediately
    }


    //////////////////////////////////////////////////
    // Core

    /// Registers a task in the group under given taskId.
    public func register(task: TaskType, taskId: String = NSUUID().UUIDString) {
        tasks[taskId] = task
        if startsImmediately {
            task.start()
        }
    }


    //////////////////////////////////////////////////
    // TaskType

    /// Starts all the managed tasks, if they are not started already.
    public func start() {
        for (_, task) in tasks {
            task.start()
        }
    }

}


//////////////////////////////////////////////////
// Task + TaskGroup

public extension Task {

    /// Registers a task in a given TaskGroup.
    public func registerIn(group: TaskGroup, taskId: String? = nil) {
        guard let taskId = taskId else {
            group.register(self); return
        }
        group.register(self, taskId: taskId)
    }
}
