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
     See `TaskGroup` for more detail.
     */
    public func registerIn(_ group: TaskGroup, taskId: String? = nil) {
        guard let taskId = taskId else {
            group.register(self); return
        }
        group.register(self, taskId: taskId)
    }

}
