import XCTest
import Chop

class TaskTests: XCTestCase {

    var group: TaskGroup!

    override func setUp() {
        super.setUp()
        group = TaskGroup()
    }

    override func tearDown() {
        super.tearDown()
        group = nil
    }


    func test_SuccessFlow() {
        var invocationCount = 0
        var isCompleted = false
        var retVal = 0

        let task = Task<Int, NSError> { handler in
            invocationCount++;
            handler(.Update(42))
            handler(.Completion)
            return {}
        }

        task
            .onUpdate {
                retVal = $0
            }
            .onCompletion {
                isCompleted = true
            }
            .registerIn(group)

        XCTAssertTrue(isCompleted)
        XCTAssertEqual(invocationCount, 1)
        XCTAssertEqual(retVal, 42)
    }

    func test_FailureFlow() {
        let task = Task<Int, NSError> { handler in
            handler(.Failure(NSError(domain: "test", code: 100, userInfo: nil)))
            handler(.Completion)
            return {}
        }

        var onUpdateCnt = 0
        var onFailureCnt = 0
        var isCompleted = false
        var error: NSError? = nil

        task
            .onUpdate { _ in
                onUpdateCnt++
            }
            .onFailure {
                onFailureCnt++
                error = $0
            }
            .onCompletion {
                isCompleted = true
            }
            .registerIn(group)

        XCTAssertTrue(isCompleted)
        XCTAssertEqual(onUpdateCnt, 0)
        XCTAssertEqual(onFailureCnt, 1)
        XCTAssertEqual(error?.code, 100)
    }

    func test_OnMultipleUpdates_shouldSaveLastValue() {

        let task = Task<String, NSError> { handler in
            handler(.Update("How"))
            handler(.Update("You"))
            handler(.Update("Doin'?"))
            handler(.Completion)
            return {}
        }

        var retVal: String?
        var onUpdateCnt = 0

        task
            .onUpdate {
                onUpdateCnt++
                retVal = $0
            }
            .registerIn(group)

        XCTAssertEqual(onUpdateCnt, 3)
        XCTAssertEqual(retVal, "Doin'?")
    }

    func test_ShouldStartOnlyOnce() {

        var invocationCount = 0

        let task = Task<Void, NSError> { handler in
            invocationCount++
            handler(.Completion)
            return {}
        }

        var onCompletionCount = 0

        task
            .onCompletion {
                onCompletionCount++
            }
            .registerIn(group)

        task.start()
        task.start()
        task.start()

        XCTAssertEqual(invocationCount, 1)
        XCTAssertEqual(onCompletionCount, 1)
    }

    func test_CreateWithResult() {
        let task = Task<String, NSError>(value: "Test")
        var ret: String?

        task
            .onUpdate {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, "Test")
    }

    func test_CreateWithError() {
        let task = Task<String, NSError>(error: NSError(domain: "test", code: 404, userInfo: nil))
        var ret: NSError?

        task
            .onFailure {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, NSError(domain: "test", code: 404, userInfo: nil))
    }

    func test_CancelIsSilent() {

        let task = Task<Int, NSError> { handler in
            handler(.Update(42))
            return { handler(.Update(21)) }
        }

        var ret = 0

        task
            .onUpdate {
                ret = $0
            }
            .registerIn(group)

        task.cancel()

        XCTAssertEqual(ret, 42)
    }

    func test_CancelDisposes() {

        var disposeCnt = 0

        let task = Task<Int, NSError> { handler in
            handler(.Completion)
            return { disposeCnt++ }
        }

        task.registerIn(group)
        task.cancel()

        XCTAssertEqual(disposeCnt, 1)
    }
}
