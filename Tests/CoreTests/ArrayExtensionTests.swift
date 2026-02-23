import SwiftLintCore
import TestHelpers
import XCTest

final class ArrayExtensionTests: SwiftLintTestCase {
    func testUnique() {
        XCTAssertEqual(([] as [Int]).unique, [])
        XCTAssertEqual([1].unique, [1])
        XCTAssertEqual([1, 2].unique, [1, 2])
        XCTAssertEqual([1, 1].unique, [1])
        XCTAssertEqual([1, 2, 1].unique, [1, 2])
        XCTAssertEqual([1, 2, 1, 3].unique, [1, 2, 3])
        XCTAssertEqual(["a", "b", "a"].unique, ["a", "b"])
    }

    func testUniquePreservesOrder() {
        let array = [3, 1, 2, 3, 2, 1]
        XCTAssertEqual(array.unique, [3, 1, 2])
    }

    func testArrayOfHashable() {
        XCTAssertEqual(Array<Int>.array(of: [1, 2]), [1, 2])
        XCTAssertEqual(Array<Int>.array(of: 1), [1])
        XCTAssertEqual(Array<Int>.array(of: Set([1]))?.sorted(), [1])
        XCTAssertNil(Array<Int>.array(of: "string"))
        XCTAssertNil(Array<Int>.array(of: nil))
    }

    func testArrayOfNonHashable() {
        struct NonHashable: Equatable {
            let id: Int
        }

        let obj = NonHashable(id: 1)
        XCTAssertEqual(Array<NonHashable>.array(of: obj), [obj])
        XCTAssertEqual(Array<NonHashable>.array(of: [obj]), [obj])
        XCTAssertNil(Array<NonHashable>.array(of: "string"))
    }

    func testGroupBy() {
        let array = ["one", "two", "three", "four"]
        let grouped = array.group(by: { $0.count })
        XCTAssertEqual(grouped[3], ["one", "two"])
        XCTAssertEqual(grouped[4], ["four"])
        XCTAssertEqual(grouped[5], ["three"])
    }

    func testFilterGroup() {
        let array = ["one", "two", "three", "four"]
        let grouped = array.filterGroup(by: { $0.count == 3 ? $0.first : nil })
        XCTAssertEqual(grouped["o"], ["one"])
        XCTAssertEqual(grouped["t"], ["two"])
        XCTAssertNil(grouped["f"])
    }

    func testParallelFilterGroup() {
        let array = Array(0..<100)
        let grouped = array.parallelFilterGroup { $0 % 2 == 0 ? "even" : "odd" }
        XCTAssertEqual(grouped["even"]?.count, 50)
        XCTAssertEqual(grouped["odd"]?.count, 50)
        XCTAssertEqual(grouped["even"]?.sorted(), array.filter { $0 % 2 == 0 })
    }

    func testPartitioned() {
        let array = [1, 2, 3, 4, 5, 6]
        let (first, second) = array.partitioned(by: { $0 % 2 == 0 })
        XCTAssertEqual(Array(first).sorted(), [1, 3, 5])
        XCTAssertEqual(Array(second).sorted(), [2, 4, 6])
    }

    func testParallelMap() {
        let array = Array(0..<100)
        let mapped = array.parallelMap { $0 * 2 }
        XCTAssertEqual(mapped, array.map { $0 * 2 })
    }

    func testParallelCompactMap() {
        let array = Array(0..<100)
        let mapped = array.parallelCompactMap { $0 % 2 == 0 ? $0 : nil }
        XCTAssertEqual(mapped, array.compactMap { $0 % 2 == 0 ? $0 : nil })
    }

    func testParallelFlatMap() {
        let array = Array(0..<10)
        let mapped = array.parallelFlatMap { [$0, $0] }
        XCTAssertEqual(mapped, array.flatMap { [$0, $0] })
    }
}
