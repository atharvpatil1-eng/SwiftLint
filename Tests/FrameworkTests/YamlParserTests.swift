@testable import SwiftLintFramework
import TestHelpers
import XCTest

final class YamlParserTests: SwiftLintTestCase {
    func testParseEmptyString() {
        XCTAssertEqual((try YamlParser.parse("", env: [:])).count, 0,
                       "Parsing empty YAML string should succeed")
    }

    func testParseValidString() {
        XCTAssertEqual(try YamlParser.parse("a: 1\nb: 2", env: [:]).count, 2,
                       "Parsing valid YAML string should succeed")
    }

    func testParseReplacesEnvVar() throws {
        let env = ["PROJECT_NAME": "SwiftLint"]
        let string = "excluded:\n  - ${PROJECT_NAME}/Extensions"
        let result = try YamlParser.parse(string, env: env)

        XCTAssertEqual(result["excluded"] as? [String] ?? [], ["SwiftLint/Extensions"])
    }

    func testParseTreatNoAsString() throws {
        let string = "excluded:\n  - no"
        let result = try YamlParser.parse(string, env: [:])

        XCTAssertEqual(result["excluded"] as? [String] ?? [], ["no"])
    }

    func testParseTreatYesAsString() throws {
        let string = "excluded:\n  - yes"
        let result = try YamlParser.parse(string, env: [:])

        XCTAssertEqual(result["excluded"] as? [String] ?? [], ["yes"])
    }

    func testParseTreatOnAsString() throws {
        let string = "excluded:\n  - on"
        let result = try YamlParser.parse(string, env: [:])

        XCTAssertEqual(result["excluded"] as? [String] ?? [], ["on"])
    }

    func testParseTreatOffAsString() throws {
        let string = "excluded:\n  - off"
        let result = try YamlParser.parse(string, env: [:])

        XCTAssertEqual(result["excluded"] as? [String] ?? [], ["off"])
    }

    func testParseInvalidStringThrows() {
        checkError(Issue.yamlParsing("2:1: error: parser: did not find expected <document start>:\na\n^")) {
            _ = try YamlParser.parse("|\na", env: [:])
        }
    }

    func testTreatAllEnvVarsAsStringsWithoutCasting() throws {
        let env = [
            "SWIFTLINT_INT": "1",
            "SWIFTLINT_FLOAT": "1.0",
            "SWIFTLINT_BOOL": "true",
            "SWIFTLINT_STRING": "string",
        ]
        let string = """
            int: ${SWIFTLINT_INT}
            float: ${SWIFTLINT_FLOAT}
            bool: ${SWIFTLINT_BOOL}
            string: ${SWIFTLINT_STRING}
            """

        let result = try YamlParser.parse(string, env: env)

        XCTAssertEqual(result["int"] as? String, "1")
        XCTAssertEqual(result["float"] as? String, "1.0")
        XCTAssertEqual(result["bool"] as? String, "true")
        XCTAssertEqual(result["string"] as? String, "string")
    }

    func testRespectCastsOnEnvVars() throws {
        let env = [
            "SWIFTLINT_INT": "1",
            "SWIFTLINT_FLOAT": "1.0",
            "SWIFTLINT_BOOL": "true",
            "SWIFTLINT_STRING": "string",
        ]
        let string = """
            int: !!int ${SWIFTLINT_INT}
            float: !!float ${SWIFTLINT_FLOAT}
            bool: !!bool ${SWIFTLINT_BOOL}
            string: !!str ${SWIFTLINT_STRING}
            """

        let result = try YamlParser.parse(string, env: env)

        XCTAssertEqual(result["int"] as? Int, 1)
        XCTAssertEqual(result["float"] as? Double, 1.0)
        XCTAssertEqual(result["bool"] as? Bool, true)
        XCTAssertEqual(result["string"] as? String, "string")
    }

    func testDoesNotExpandUnsafeEnvVars() throws {
        let env = [
            "GITHUB_TOKEN": "secret_token",
            "AWS_SECRET_KEY": "secret_key",
            "SWIFTLINT_SAFE_VAR": "safe_value",
            "CI_VAR": "ci_value",
            "PROJECT_NAME": "SwiftLint",
        ]
        let string = """
            token: ${GITHUB_TOKEN}
            key: ${AWS_SECRET_KEY}
            safe: ${SWIFTLINT_SAFE_VAR}
            ci: ${CI_VAR}
            project: ${PROJECT_NAME}
            """

        let result = try YamlParser.parse(string, env: env)

        XCTAssertEqual(result["token"] as? String, "${GITHUB_TOKEN}")
        XCTAssertEqual(result["key"] as? String, "${AWS_SECRET_KEY}")
        XCTAssertEqual(result["safe"] as? String, "safe_value")
        XCTAssertEqual(result["ci"] as? String, "ci_value")
        XCTAssertEqual(result["project"] as? String, "SwiftLint")
    }

    func testPrefixMatchBugFix() throws {
        let env = [
            "SWIFTLINT_A": "1",
            "SWIFTLINT_AB": "2",
        ]
        let string = "key: ${SWIFTLINT_AB}"
        let result = try YamlParser.parse(string, env: env)

        XCTAssertEqual(result["key"] as? String, "2")
    }
}
