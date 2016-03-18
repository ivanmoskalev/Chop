//
//  Task+TaskGroup.swift
//  Pods
//
//  Created by Ivan Moskalev on 18/03/16.
//
//

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
