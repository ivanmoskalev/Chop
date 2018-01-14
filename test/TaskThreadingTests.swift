import Chop
import XCTest

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
      .switchTo(.main)
      .onUpdate { _ in
        hit = true
      }
      .registerIn(group)

    XCTAssertTrue(hit)
  }

  func test_MainFromBackground() {
    let expectation = self.expectation(description: "isMain")

    Task<String, NSError> { handler in
      DispatchQueue.global(qos: .background).async(execute: {
        handler(.completion)
      })
      return {}
    }
    .switchTo(.main)
    .onCompletion {
      if Thread.isMainThread {
        expectation.fulfill()
      }
    }
    .registerIn(group)

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func test_Background() {
    var hitNow = false
    let expectation = self.expectation(description: "background")

    Task<String, NSError>(value: "Test")
      .switchTo(.background)
      .onUpdate { _ in
        hitNow = true
        expectation.fulfill()
      }
      .registerIn(group)

    XCTAssertFalse(hitNow)
    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
