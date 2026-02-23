import SourceKittenFramework
import SwiftLintCore
import TestHelpers
import XCTest

final class SyntaxKindTests: SwiftLintTestCase {
    func testInitWithShortName() {
        XCTAssertEqual(SyntaxKind(shortName: "keyword"), .keyword)
        XCTAssertEqual(SyntaxKind(shortName: "string"), .string)
        XCTAssertEqual(SyntaxKind(shortName: "identifier"), .identifier)
        XCTAssertEqual(SyntaxKind(shortName: "comment"), .comment)
    }

    func testInitWithShortNameCaseInsensitivity() {
        XCTAssertEqual(SyntaxKind(shortName: "KEYWORD"), .keyword)
        XCTAssertEqual(SyntaxKind(shortName: "String"), .string)
        XCTAssertEqual(SyntaxKind(shortName: "IdEnTiFiEr"), .identifier)
    }

    func testInitWithShortNameReturnsNilForInvalidName() {
        XCTAssertNil(SyntaxKind(shortName: "nonexistent"))
        XCTAssertNil(SyntaxKind(shortName: ""))
        XCTAssertNil(SyntaxKind(shortName: "invalid!@#"))
    }
}
