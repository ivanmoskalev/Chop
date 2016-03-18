//
// Event.swift
// Chop
//
// Copyright (C) 2016 Ivan Moskalev
//
// This software may be modified and distributed under the terms of the MIT license.
// See the LICENSE file for details.
//

/**
 The events that can be dispatched by the task.
 */
public enum Event<V, E> {
    /// An update to yielded value. This can be a final or a non-final update.
    case Update(_: V)
    /// A faiulre. Automatically triggers `.Completion` after being dispatched.
    case Failure(_: E)
    /// The completion – it means that the task is finished and can be disposed of.
    case Completion
}
