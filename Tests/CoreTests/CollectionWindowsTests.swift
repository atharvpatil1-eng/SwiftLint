import SwiftLintCore
import TestHelpers
import XCTest

final class CollectionWindowsTests: SwiftLintTestCase {
    func testWindowsOfCount() {
        let array = [1, 2, 3, 4, 5]

        // Window size 3
        let windows3 = array.windows(ofCount: 3)
        XCTAssertEqual(windows3.count, 3)
        XCTAssertEqual(Array(windows3[windows3.startIndex]), [1, 2, 3])
        XCTAssertEqual(Array(windows3[windows3.index(after: windows3.startIndex)]), [2, 3, 4])
        XCTAssertEqual(Array(windows3.last!), [3, 4, 5])

        let expected3 = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
        XCTAssertEqual(windows3.map(Array.init), expected3)

        // Window size 1
        let windows1 = array.windows(ofCount: 1)
        let expected1 = [[1], [2], [3], [4], [5]]
        XCTAssertEqual(windows1.map(Array.init), expected1)

        // Window size equals count
        let windows5 = array.windows(ofCount: 5)
        let expected5 = [[1, 2, 3, 4, 5]]
        XCTAssertEqual(windows5.map(Array.init), expected5)

        // Window size greater than count
        let windows6 = array.windows(ofCount: 6)
        XCTAssertTrue(windows6.isEmpty)

        // Empty array
        let emptyArray: [Int] = []
        let windowsEmpty = emptyArray.windows(ofCount: 3)
        XCTAssertTrue(windowsEmpty.isEmpty)
    }

    func testIndices() {
        let array = [1, 2, 3, 4]
        let windows = array.windows(ofCount: 2)
        // Windows: [1, 2], [2, 3], [3, 4]

        var index = windows.startIndex
        XCTAssertEqual(Array(windows[index]), [1, 2])

        index = windows.index(after: index)
        XCTAssertEqual(Array(windows[index]), [2, 3])

        index = windows.index(after: index)
        XCTAssertEqual(Array(windows[index]), [3, 4])

        index = windows.index(after: index)
        XCTAssertEqual(index, windows.endIndex)
    }

    func testBidirectionalCollection() {
        let array = [1, 2, 3, 4]
        let windows = array.windows(ofCount: 2)
        // Windows: [1, 2], [2, 3], [3, 4]

        var index = windows.endIndex
        index = windows.index(before: index)
        XCTAssertEqual(Array(windows[index]), [3, 4])

        index = windows.index(before: index)
        XCTAssertEqual(Array(windows[index]), [2, 3])

        index = windows.index(before: index)
        XCTAssertEqual(Array(windows[index]), [1, 2])

        XCTAssertEqual(index, windows.startIndex)
    }

    func testDistance() {
        let array = [1, 2, 3, 4, 5]
        let windows = array.windows(ofCount: 2)
        // Windows: [1, 2], [2, 3], [3, 4], [4, 5]
        // Count should be 4

        XCTAssertEqual(windows.distance(from: windows.startIndex, to: windows.endIndex), 4)
        XCTAssertEqual(windows.distance(from: windows.endIndex, to: windows.startIndex), -4)

        let secondIndex = windows.index(after: windows.startIndex)
        XCTAssertEqual(windows.distance(from: windows.startIndex, to: secondIndex), 1)
    }
}
