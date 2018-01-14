import Chop
import XCTest

class TaskGroupTests: XCTestCase {

  var group: TaskGroup!

  override func setUp() {
    super.setUp()
    group = TaskGroup()
  }

  override func tearDown() {
    super.tearDown()
    group = nil
  }

  func test_IgnorePolicy() {
    var taskOneExecutionCnt = 0

    Task<Int, NSError> {
      taskOneExecutionCnt += 1
      $0(.update(1))
      return {}
    }
    .registerIn(group, taskId: "task")

    var taskTwoExecutionCnt = 0

    Task<Int, NSError> {
      taskTwoExecutionCnt += 1
      $0(.completion)
      return {}
    }
    .registerIn(group, taskId: "task")

    XCTAssertEqual(taskOneExecutionCnt, 1)
    XCTAssertEqual(taskTwoExecutionCnt, 0)
  }

  func test_ReplacePolicy() {
    group = TaskGroup(policy: .replace)
    var taskOneDisposeCnt = 0

    Task<Int, NSError> {
      $0(.completion)
      return { taskOneDisposeCnt += 1 }
    }
    .registerIn(group, taskId: "task")

    var taskTwoExecutionCnt = 0

    Task<Int, NSError> {
      taskTwoExecutionCnt += 1
      $0(.completion)
      return {}
    }
    .registerIn(group, taskId: "task")

    XCTAssertEqual(taskOneDisposeCnt, 1)
    XCTAssertEqual(taskTwoExecutionCnt, 1)
  }

  func test_DeferredStart() {
    group = TaskGroup(startsImmediately: false)
    var taskOneExecutionCnt = 0

    Task<Int, NSError> {
      taskOneExecutionCnt += 1
      $0(.update(1))
      return {}
    }
    .registerIn(group)

    var taskTwoExecutionCnt = 0

    Task<Int, NSError> {
      taskTwoExecutionCnt += 1
      $0(.completion)
      return {}
    }
    .registerIn(group)

    XCTAssertEqual(taskOneExecutionCnt, 0)
    XCTAssertEqual(taskTwoExecutionCnt, 0)

    group.start()

    XCTAssertEqual(taskOneExecutionCnt, 1)
    XCTAssertEqual(taskTwoExecutionCnt, 1)
  }

  func test_Cancel() {
    var taskOneDisposeCnt = 0

    Task<Int, NSError> { _ in
      return { taskOneDisposeCnt += 1 }
    }
    .registerIn(group)

    var taskTwoDisposeCnt = 0

    Task<Int, NSError> { _ in
      return { taskTwoDisposeCnt += 1 }
    }
    .registerIn(group)

    group.cancel()

    XCTAssertEqual(taskOneDisposeCnt, 1)
    XCTAssertEqual(taskTwoDisposeCnt, 1)
  }

  func test_IsFinished_ShouldAlwaysReturnFalse() {
    XCTAssertEqual(group.isFinished(), false)
  }
}
