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
            invocationCount += 1
            handler(.update(42))
            handler(.completion)
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
            handler(.failure(NSError(domain: "test", code: 100, userInfo: nil)))
            handler(.completion)
            return {}
        }

        var onUpdateCnt = 0
        var onFailureCnt = 0
        var isCompleted = false
        var error: NSError? = nil

        task
            .onUpdate { _ in
                onUpdateCnt += 1
            }
            .onFailure {
                onFailureCnt += 1
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
            handler(.update("How"))
            handler(.update("You"))
            handler(.update("Doin'?"))
            handler(.completion)
            return {}
        }

        var retVal: String?
        var onUpdateCnt = 0

        task
            .onUpdate {
                onUpdateCnt += 1
                retVal = $0
            }
            .registerIn(group)

        XCTAssertEqual(onUpdateCnt, 3)
        XCTAssertEqual(retVal, "Doin'?")
    }

    func test_ShouldStartOnlyOnce() {

        var invocationCount = 0

        let task = Task<Void, NSError> { handler in
            invocationCount += 1
            handler(.completion)
            return {}
        }

        var onCompletionCount = 0

        task
            .onCompletion {
                onCompletionCount += 1
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
            handler(.update(42))
            return { handler(.update(21)) }
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
            handler(.completion)
            return { disposeCnt += 1 }
        }

        task.registerIn(group)
        task.cancel()

        XCTAssertEqual(disposeCnt, 1)
    }

    func test_RetryThenSucceed() {

        var hitCnt = 0

        let task = Task<Int, NSError> { handler in
            hitCnt += 1
            if hitCnt == 5 {
                handler(.update(42))
                handler(.completion)
            }
            else {
                handler(.failure(NSError(domain: "tst", code: 100, userInfo: nil)))
            }

            return {}
        }

        var value = 0

        task.retry(5)
            .onUpdate { value = $0 }
            .registerIn(group)

        XCTAssertEqual(hitCnt, 5)
        XCTAssertEqual(value, 42)
    }

    func test_RetryAllFail() {

        var hitCnt = 0

        let task = Task<Int, NSError> { handler in
            hitCnt += 1
            handler(.failure(NSError(domain: "tst", code: 100, userInfo: nil)))
            return {}
        }

        var value = 0

        task.retry(5)
            .onUpdate { value = $0 }
            .registerIn(group)

        XCTAssertEqual(hitCnt, 6)
        XCTAssertEqual(value, 0)
    }
}
