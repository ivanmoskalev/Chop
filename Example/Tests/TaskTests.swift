
import XCTest
import Chop

class Tests: XCTestCase {

    func test_successFlow() {
        var invocationCount = 0
        var isCompleted = false
        var retVal = 0

        let task = Task<Int, NSError> { handler in
            invocationCount++;
            handler(.Update(value: 42))
            handler(.Completion)
            return {}
        }

        let group = TaskGroup()

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

    func test_failureFlow() {
        let task = Task<Int, NSError> { handler in
            handler(.Failure(error: NSError(domain: "test", code: 100, userInfo: nil)))
            handler(.Completion)
            return {}
        }

        var onUpdateCnt = 0
        var onFailureCnt = 0
        var isCompleted = false
        var error: NSError? = nil

        let group = TaskGroup()

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

    func test_onMultipleUpdates_shouldSaveLastValue() {

        let task = Task<String, NSError> { handler in
            handler(.Update(value: "How"))
            handler(.Update(value: "You"))
            handler(.Update(value: "Doin'?"))
            handler(.Completion)
            return {}
        }

        var retVal: String?
        var onUpdateCnt = 0

        let group = TaskGroup()

        task
            .onUpdate {
                onUpdateCnt++
                retVal = $0
            }
            .registerIn(group)

        XCTAssertEqual(onUpdateCnt, 3)
        XCTAssertEqual(retVal, "Doin'?")
    }

    func test_shouldStartOnlyOnce() {

        var invocationCount = 0

        let task = Task<Void, NSError> { handler in
            invocationCount++
            handler(.Completion)
            return {}
        }

        var onCompletionCount = 0
        let group = TaskGroup()

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

    func test_createWithResult() {
        let task = Task<String, NSError>(value: "Test")
        var ret: String?

        let group = TaskGroup()

        task
            .onUpdate {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, "Test")
    }

    func test_createWithError() {
        let task = Task<String, NSError>(error: NSError(domain: "test", code: 404, userInfo: nil))
        var ret: NSError?

        let group = TaskGroup()

        task
            .onFailure {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, NSError(domain: "test", code: 404, userInfo: nil))
    }
    
}
