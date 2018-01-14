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
  case main
  case background
}

//////////////////////////////////////////////////
// Internal

internal extension Scheduler {

  func perform(_ block: @escaping () -> Void) {
    switch self {
    case .main:
      dispatchMain(block)
    case .background:
      DispatchQueue.global(qos: .background).async(execute: block)
    }
  }

  func dispatchMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      block()
      return
    }
    DispatchQueue.main.async(execute: block)
  }
}
