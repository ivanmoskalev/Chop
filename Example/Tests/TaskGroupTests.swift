import XCTest
import Chop

class TaskGroupTests: XCTestCase {

    var group : TaskGroup!

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
            taskOneExecutionCnt++
            $0(.Update(1))
            return {}
        }
        .registerIn(group, taskId: "task")

        var taskTwoExecutionCnt = 0

        Task<Int, NSError> {
            taskTwoExecutionCnt++
            $0(.Completion)
            return {}
        }
        .registerIn(group, taskId: "task")

        XCTAssertEqual(taskOneExecutionCnt, 1)
        XCTAssertEqual(taskTwoExecutionCnt, 0)
    }

    func test_ReplacePolicy() {

        group = TaskGroup(policy: .Replace)

        var taskOneDisposeCnt = 0

        Task<Int, NSError> {
            $0(.Completion)
            return { taskOneDisposeCnt++ }
        }
        .registerIn(group, taskId: "task")

        var taskTwoExecutionCnt = 0

        Task<Int, NSError> {
            taskTwoExecutionCnt++
            $0(.Completion)
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
            taskOneExecutionCnt++
            $0(.Update(1))
            return {}
        }
        .registerIn(group)

        var taskTwoExecutionCnt = 0

        Task<Int, NSError> {
            taskTwoExecutionCnt++
            $0(.Completion)
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
                return { taskOneDisposeCnt++ }
            }
            .registerIn(group)

        var taskTwoDisposeCnt = 0

        Task<Int, NSError> { _ in
                return { taskTwoDisposeCnt++ }
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