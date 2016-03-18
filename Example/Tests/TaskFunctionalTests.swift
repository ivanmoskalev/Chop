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
            .then { $0 + " number one" }
            .onUpdate {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, "Test number one")
    }

    func test_FlatMap() {
        var ret: Int?

        Task<String, NSError>(value: "Test")
            .then {
                return Task<Int, NSError>(value: $0.hash)
            }
            .onUpdate {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, "Test".hash)
    }

    func test_Recover() {
        var ret: String?

        Task<String, NSError>(error: NSError(domain: "test", code: 42, userInfo: nil))
            .recover({ "Error with code: \($0.code)" })
            .onUpdate {
                ret = $0
            }
            .registerIn(group)

        XCTAssertEqual(ret, "Error with code: 42")
    }

}
