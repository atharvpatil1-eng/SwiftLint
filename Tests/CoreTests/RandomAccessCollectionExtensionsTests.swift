import SwiftLintCore
import TestHelpers
import XCTest

final class RandomAccessCollectionExtensionsTests: SwiftLintTestCase {
    func testFirstIndexAssumingSortedWithArray() {
        let array = [1, 3, 5, 7, 9]

        // Present
        XCTAssertEqual(array.firstIndexAssumingSorted(where: { $0 >= 5 }), 2)
        XCTAssertEqual(array.firstIndexAssumingSorted(where: { $0 >= 1 }), 0)
        XCTAssertEqual(array.firstIndexAssumingSorted(where: { $0 >= 9 }), 4)

        // Absent (all false)
        XCTAssertNil(array.firstIndexAssumingSorted(where: { $0 >= 10 }))

        // Absent (all true) -> returns first element
        XCTAssertEqual(array.firstIndexAssumingSorted(where: { $0 >= 0 }), 0)
    }

    func testFirstIndexAssumingSortedWithArraySlice() {
        let array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let slice = array[5...] // Indices 5..<10, values [5, 6, 7, 8, 9]

        // Present in slice
        XCTAssertEqual(slice.firstIndexAssumingSorted(where: { $0 >= 7 }), 7)
        XCTAssertEqual(slice.firstIndexAssumingSorted(where: { $0 >= 5 }), 5)
        XCTAssertEqual(slice.firstIndexAssumingSorted(where: { $0 >= 9 }), 9)

        // Absent in slice (all false)
        XCTAssertNil(slice.firstIndexAssumingSorted(where: { $0 >= 10 }))

        // Absent in slice (all true) -> returns first element of slice
        XCTAssertEqual(slice.firstIndexAssumingSorted(where: { $0 >= 4 }), 5)
    }

    func testFirstIndexAssumingSortedRethrows() {
        struct TestError: Error {}
        let array = [1]
        XCTAssertThrowsError(try array.firstIndexAssumingSorted { _ in throw TestError() })
    }
}
