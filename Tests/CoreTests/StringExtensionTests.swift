import SwiftLintCore
import TestHelpers
import XCTest

final class StringExtensionTests: SwiftLintTestCase {
    func testRelativePathExpression() {
        XCTAssertEqual("Folder/Test", "Root/Folder/Test".path(relativeTo: "Root"))
        XCTAssertEqual("Test", "Root/Folder/Test".path(relativeTo: "Root/Folder"))
        XCTAssertEqual("", "Root/Folder/Test".path(relativeTo: "Root/Folder/Test"))
        XCTAssertEqual("../Test", "Root/Folder/Test".path(relativeTo: "Root/Folder/SubFolder"))
        XCTAssertEqual("../..", "Root".path(relativeTo: "Root/Folder/SubFolder"))
        XCTAssertEqual("../../OtherFolder/Test", "Root/OtherFolder/Test".path(relativeTo: "Root/Folder/SubFolder"))
        XCTAssertEqual("../MyFolder123", "Folder/MyFolder123".path(relativeTo: "Folder/MyFolder"))
        XCTAssertEqual("../MyFolder123", "Folder/MyFolder123".path(relativeTo: "Folder/MyFolder/"))
        XCTAssertEqual("Test", "Root////Folder///Test/".path(relativeTo: "Root//Folder////"))
        XCTAssertEqual("Root/Folder/Test", "Root/Folder/Test/".path(relativeTo: ""))
    }

    func testIndent() {
        XCTAssertEqual("string".indent(by: 3), "   string")
        XCTAssertEqual(" string".indent(by: 2), "   string")
        XCTAssertEqual("""
            1
            2
            3
            """.indent(by: 2), """
              1
              2
              3
            """
        )
    }

    func testCharacterPosition() {
        XCTAssertNil("string".characterPosition(of: -1))
        XCTAssertEqual("string".characterPosition(of: 0), 0)
        XCTAssertEqual("string".characterPosition(of: 1), 1)
        XCTAssertNil("string".characterPosition(of: 6))
        XCTAssertNil("string".characterPosition(of: 7))

        XCTAssertEqual("s🤵🏼‍♀️s".characterPosition(of: 0), 0)
        XCTAssertEqual("s🤵🏼‍♀️s".characterPosition(of: 1), 1)
        for bytes in 2...17 {
            XCTAssertNil("s🤵🏼‍♀️s".characterPosition(of: bytes))
        }
        XCTAssertEqual("s🤵🏼‍♀️s".characterPosition(of: 18), 2)
        XCTAssertNil("s🤵🏼‍♀️s".characterPosition(of: 19))
    }

    func testHasTrailingWhitespace() {
        // Case: Empty string
        XCTAssertFalse("".hasTrailingWhitespace())

        // Case: No trailing whitespace
        XCTAssertFalse("string".hasTrailingWhitespace())

        // Case: Trailing space
        XCTAssertTrue("string ".hasTrailingWhitespace())

        // Case: Trailing tab
        XCTAssertTrue("string\t".hasTrailingWhitespace())

        // Case: Trailing newline (not considered whitespace in CharacterSet.whitespaces)
        XCTAssertFalse("string\n".hasTrailingWhitespace())
        XCTAssertFalse("string\r\n".hasTrailingWhitespace())

        // Case: Trailing whitespace followed by newline
        XCTAssertFalse("string \n".hasTrailingWhitespace())

        // Case: Whitespace only
        XCTAssertTrue(" ".hasTrailingWhitespace())

        // Case: Non-breaking space
        // U+00A0 IS in CharacterSet.whitespaces
        XCTAssertTrue("string\u{00A0}".hasTrailingWhitespace())
    }
}
