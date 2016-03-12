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

    /**
     An enumeration defining the behavior of the `TaskGroup` when a new task is added with an identifier that is already used in this `TaskGroup`.
     */
    public enum Policy {
        /// The new task replaces the old one, terminating it.
        case Replace
        /// The new task is ignored and terminated, if there are no other references to it.
        case Ignore
    }

    /// A dictionary of tasks retrievable by task identifiers.
    private(set) var tasks = [String : TaskType]()

    /// Whether the tasks should start immediately upon being added.
    public let startsImmediately: Bool

    /// The policy defining how to treat a new task with a conflicting identifier. For list of possible values see `Policy`.
    public let policy: Policy


    //////////////////////////////////////////////////
    // Init

    /**
    Creates a `TaskGroup` with supplied options.

    - parameter policy:            The policy defining how to treat a new task with a conflicting identifier. Default is `Policy.Ignore`.
    - parameter startsImmediately: Whether the tasks should be started immediately upon addition. Default is `true`.

    - returns: An instance of `TaskGroup`.
    */
    public init(policy: Policy = .Ignore, startsImmediately: Bool = true) {
        self.policy = policy
        self.startsImmediately = startsImmediately
    }


    //////////////////////////////////////////////////
    // Core

    /**
    Registers a task in the group under given identifier. 
    
    If a task with a given identifier is already in the queue, the behavior is defined by `policy` property of a `TaskGroup`. 
    
    By default the task is registered with an unique identifier.

    - parameter task:   An object of `TaskType` to register.
    - parameter taskId: Optional. The identifier of this task. Default value is an UUID string.
    */
    public func register(task: TaskType, taskId: String = NSUUID().UUIDString) {
        if policy == .Replace || tasks[taskId] == nil {
            tasks[taskId] = task
            if startsImmediately { task.start() }
        }
    }


    //////////////////////////////////////////////////
    // TaskType

    /**
    Starts all the managed tasks, if they are not started already.
    
    If `startsImmediately` is true, this method is a de-facto no-op.
    */
    public func start() {
        for (_, task) in tasks {
            task.start()
        }
    }

}


//////////////////////////////////////////////////
// Task + TaskGroup

public extension Task {

    /**
     Registers a task in a given `TaskGroup`.

     - parameter group:  The task group in which a task should be registered.
     - parameter taskId: The identifier of the task. The default value of nil means that a unique identifier will be used. See `TaskGroup` for more detail.
     */
    public func registerIn(group: TaskGroup, taskId: String? = nil) {
        guard let taskId = taskId else {
            group.register(self); return
        }
        group.register(self, taskId: taskId)
    }
}
