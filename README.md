# Chop

Lazy, cancellable, progressive tasks with intuitive and lightweight resource management mechanism based on [RAII](https://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization) concept. Easy-peasy testing included.

[![CI Status](https://travis-ci.org/ivanmoskalev/Chop.svg?branch=master)](https://travis-ci.org/ivanmoskalev/Chop)
[![codecov.io](https://codecov.io/github/ivanmoskalev/Chop/coverage.svg?branch=master)](https://codecov.io/github/ivanmoskalev/Chop?branch=master)
[![Version](https://img.shields.io/cocoapods/v/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)
[![License](https://img.shields.io/cocoapods/l/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)
[![Platform](https://img.shields.io/cocoapods/p/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)

## What is Chop?

Chop is a Swift microframework providing two simple classes, which provide implementations async ***tasks*** and ***task groups***.

- **Tasks** are abstractions over asynchronous processes that can yield several values during their lifetime (think of progressive images or cached-then-remote values). They can also finish with an error. Tasks are lazy – which means they are not started before they really need to. Furthermore, tasks are cancelled when they are no longer referenced (ie, deallocated), freeing up jobs and resources they are associated with.
- **Task Groups** are execution contexts for tasks. They allow to place uniqueness constraints on tasks and apply a variety of behaviors around that (for example, replacing existing task with the same unique ID with the new one or ignoring the latter). Task Groups also free up all tasks they manage when they are deallocated, making them a nice way to particular tasks to, say, user interface. 

Here is a small example of how Chop can be used to execute a task that progressively loads a collection of items (for example, first fetching the locally cached value, and then the remote value). As a nice bonus: subsequent similar tasks are ignored until the first one finishes:
```swift
// The context in which the tasks can execute. 
// `policy` describes what should be done if a task with an identical `taskId` is added to group.
// In this case we want to ignore subsequent tasks with the same `taskId` until the first is completed.
// Other options exist.
let taskGroup = TaskGroup(policy: .Ignore)

self.isLoading = true
self.interactor
    .fetchIssues(request, itemLimit: 10, progressive: true) // API that exposes a Chop'esque interface.
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
    // `taskId` is optional. If provided, task will be uniqued based on this id.
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
