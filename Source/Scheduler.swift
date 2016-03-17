//
// Scheduler.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

import Foundation

public enum Scheduler {
    case ImmediateMain
    case Background
}


//////////////////////////////////////////////////
// Internal

internal extension Scheduler {

    func perform(block: dispatch_block_t) {
        switch self {
        case .ImmediateMain:
            performImmediateMain(block)
        case .Background:
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
        }
    }

    func performImmediateMain(block: dispatch_block_t) {
        if NSThread.isMainThread() {
            block()
            return
        }
        dispatch_async(dispatch_get_main_queue(), block)
    }

}
