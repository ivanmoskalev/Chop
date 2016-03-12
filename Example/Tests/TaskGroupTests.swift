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
            $0(.Completion)
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

}