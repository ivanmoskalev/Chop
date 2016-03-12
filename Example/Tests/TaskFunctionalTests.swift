import XCTest
import Chop

class TaskFunctionalTests: XCTestCase {

    var group: TaskGroup!

    override func setUp() {
        super.setUp()
        group = TaskGroup()
    }

    override func tearDown() {
        super.tearDown()
        group = nil
    }

    func test_Map() {
        var ret: String?

        Task<String, NSError>(value: "Test")
            .map { $0 + " number one" }
            .onUpdate {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, "Test number one")
    }

}
