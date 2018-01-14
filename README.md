# Chop

Write synchronous, testable core easily with Chop. 

[![CI Status](https://travis-ci.org/ivanmoskalev/Chop.svg?branch=master)](https://travis-ci.org/ivanmoskalev/Chop)
[![codecov.io](https://codecov.io/github/ivanmoskalev/Chop/coverage.svg?branch=master)](https://codecov.io/github/ivanmoskalev/Chop?branch=master)
[![Version](https://img.shields.io/cocoapods/v/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)
[![License](https://img.shields.io/cocoapods/l/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)
[![Platform](https://img.shields.io/cocoapods/p/Chop.svg?style=flat)](http://cocoapods.org/pods/Chop)

## What is Chop?

Chop is a Swift microframework providing implementations of ***tasks*** and ***task groups***.

- **Tasks** are abstractions over asynchronous processes that can yield several values during their lifetime (think of progressive images or cached-then-remote values). They can also finish with an error. Tasks are lazy – which means they are not started before they really need to. Furthermore, tasks are cancelled when they are no longer referenced (i.e. deallocated), freeing up resources they are associated with.
- **Task Groups** are execution contexts for tasks. They allow to place uniqueness constraints on tasks and apply a variety of behaviors around that. Task Groups also free up all tasks they manage when they are deallocated, making them a nice way to tie particular tasks to, say, user interface. 

Here is a small example of how Chop can be used to execute a task that progressively loads a collection of items (for example, first fetching the locally cached value, and then the remote value). Only one task is allowed to execute; subsequent similar tasks are ignored until the first one finishes:
```swift
// The context in which the tasks can execute. 
// `policy` describes what should be done if a task with an identical `taskId` is added to group.
// In this case we want to ignore subsequent tasks with the same `taskId` until the first is completed.
// Other options exist.
let taskGroup = TaskGroup(policy: .ignore)

self.isLoading = true
self.interactor
  .fetchIssues(request, itemLimit: 10, progressive: true) // API that exposes a Chop'esque interface.
  .onUpdate { [weak self] in
    // Can be executed multiple times (i.e. providing first cached items, then remote items).
    self?.items = $0
  }
  .onFailure { [weak self] in
    // Executed only once if error occurs.
    self?.handleError($0)  
  }
  .onCompletion { [weak self] in
    // Executed when the task has finished, regardless of result.
    self?.isLoading = false 
  }
  // `taskId` is optional - it will be 
  .registerIn(self.taskGroup, taskId: "itemFetch")
```

The task is created like this:

```swift
func fetchIssues(request: IssueRequest, itemLimit: UInt, progressive: Bool) -> Task<[Issue]> {
  return Task {
    let localItems = self.localDB.getItems(request)
    // Send local items through to the Task subscribers.
    $0(.update(localItems))
    
    // The following operation is asynchronous.
    var urlSessionTask = self.httpClient.getItems(request) { result in
      switch result {
        // Once again send data through to the Task subscribers.
        case .success(let issues): $0(.update(issues))
        // Or, otherwise, send error.
        case .failure(let error):  $0(.error(localResponse))
      }
      $0(.completion)
    }
    
    // In this closure we perform cleanup. It will be called if the task is finished or cancelled.
    return { urlSessionTask.cancel(); urlSessionTask = nil }
  }
}
```

The task performs work only as long as it is referenced by a `TaskGroup`. Consequently, if the `TaskGroup` is destroyed, all managed tasks are interrupted and you don't have to care about them anymore.

## Requirements

`Chop` requires Swift 3.2. Swift 4 is supported as well.

## Installation

`Chop` is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Chop"
```

## Author

Ivan Moskalev, iv.s.moskalev@gmail.com

## License

Chop is available under the MIT license. See the LICENSE file for more info.
