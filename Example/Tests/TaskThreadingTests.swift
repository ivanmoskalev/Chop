import XCTest
import Chop

class TaskThreadingTests: XCTestCase {

    var group: TaskGroup!

    override func setUp() {
        super.setUp()
        group = TaskGroup()
    }

    override func tearDown() {
        super.tearDown()
        group = nil
    }

    func test_MainFromMain() {
        var hit = false

        Task<String, NSError>(value: "Test")
            .switchTo(.Main)
            .onUpdate { _ in
                hit = true
            }
            .registerIn(group)

        XCTAssertTrue(hit)
    }

    func test_MainFromBackground() {
        let expectation = expectationWithDescription("isMain")

        Task<String, NSError> { handler in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    handler(.Completion)
                })
                return {}
            }
            .switchTo(.Main)
            .onCompletion { _ in
                if NSThread.isMainThread() {
                    expectation.fulfill()
                }
            }
            .registerIn(group)

        waitForExpectationsWithTimeout(10.0, handler: nil)
    }

    func test_Background() {
        var hitNow = false
        let expectation = expectationWithDescription("background")

        Task<String, NSError>(value: "Test")
            .switchTo(.Background)
            .onUpdate { _ in
                hitNow = true
                expectation.fulfill()
            }
            .registerIn(group)

        XCTAssertFalse(hitNow)
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
}