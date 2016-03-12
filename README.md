# Chop

Lazy, cancellable, progressive tasks with intuitive and lightweight resource management mechanism. Easy-peasy testing included.

[![CI Status](https://travis-ci.org/ivanmoskalev/Chop.svg?branch=master)](https://travis-ci.org/ivanmoskalev/Chop)
[![codecov.io](https://codecov.io/github/ivanmoskalev/Chop/coverage.svg?branch=master)](https://codecov.io/github/ivanmoskalev/Chop?branch=master)
[![Version](https://img.shields.io/cocoapods/v/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)
[![License](https://img.shields.io/cocoapods/l/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)
[![Platform](https://img.shields.io/cocoapods/p/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)

## What is Chop?

Chop is a Swift microframework providing two simple classes, which abstract over async *tasks* and *groups of tasks*.

Here is how it can be used to create a task that progressively loads a collection of items (for example, first fetching the locally cached value, and then the remote value), and ignores subsequent similar tasks until the first one finishes:
```swift
let taskGroup = TaskGroup(policy: .Ignore)  // The context in which the tasks can execute.

self.isLoading = true
self.interactor
    .fetchIssues(request, itemLimit: 10, progressive: true) // API that  
    .onUpdate {
      // Can be executed multiple times (ie., providing first cached items, then remote items).
      self.items = $0
    }
    .onFailure {
      // Executed only once if error occurs.
      self.handleError($0)  
    }
    .onCompletion {
      // Executed when the task has finished, regardless of result.
      self.isLoading = false 
    }
    .registerIn(self.taskGroup, taskId: "itemFetch")
```

Imagine how much boilerplate code would you have to write to acheive this behavior. With `Chop` it is easy, declarative and rather enjoyable. 

The task performs work only as long as it is referenced by a `TaskGroup`. Consequently, if the `TaskGroup` is destroyed, all the tasks it manages are interrupted and you don't have to care about them anymore. 

## Requirements

`Chop` requires Swift 2.0.

## Installation

`Chop` is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Chop"
```

## Author

Ivan Moskalev, ivan.moskalev@gmail.com

## License

Chop is available under the MIT license. See the LICENSE file for more info.
