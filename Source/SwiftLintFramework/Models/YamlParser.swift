import Foundation
import Yams

// MARK: - YamlParser

/// An interface for parsing YAML.
struct YamlParser {
    /// Parses the input YAML string as an untyped dictionary.
    ///
    /// - parameter yaml: YAML-formatted string.
    /// - parameter env:  The environment to use to expand variables in the YAML.
    ///
    /// - returns: The parsed YAML as an untyped dictionary.
    ///
    /// - throws: Throws if the `yaml` string provided could not be parsed.
    static func parse(_ yaml: String,
                      env: [String: String] = ProcessInfo.processInfo.environment) throws -> [String: Any] {
        do {
            return try Yams.load(yaml: yaml, .default,
                                 .swiftlintConstructor(env: env)) as? [String: Any] ?? [:]
        } catch {
            throw Issue.yamlParsing("\(error)")
        }
    }
}

private extension Constructor {
    static func swiftlintConstructor(env: [String: String]) -> Constructor {
        Constructor(customScalarMap(env: env))
    }

    static func customScalarMap(env: [String: String]) -> ScalarMap {
        var map = defaultScalarMap
        map[.str] = { $0.string.expandingEnvVars(env: env) }
        map[.bool] = {
            switch $0.string.expandingEnvVars(env: env).lowercased() {
            case "true": true
            case "false": false
            default: nil
            }
        }
        map[.int] = { Int($0.string.expandingEnvVars(env: env)) }
        map[.float] = { Double($0.string.expandingEnvVars(env: env)) }
        return map
    }
}

private extension String {
    func expandingEnvVars(env: [String: String]) -> String {
        guard contains("${"),
              let regex = try? NSRegularExpression(pattern: "\\$\\{([a-zA-Z0-9_]+)\\}") else {
            return self
        }

        let safeVariables: Set = [
            "PWD", "HOME", "USER", "PROJECT_NAME", "SRCROOT", "WORKSPACE_PATH",
            "CONFIGURATION", "PLATFORM_NAME", "SDKROOT", "TEMP_DIR", "DERIVED_DATA_DIR",
        ]

        var result = self
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: utf16.count))
        for match in matches.reversed() {
            let key = (self as NSString).substring(with: match.range(at: 1))
            if key.hasPrefix("SWIFTLINT_") || key.hasPrefix("CI_") || safeVariables.contains(key),
               let value = env[key] {
                result = (result as NSString).replacingCharacters(in: match.range, with: value)
            }
        }
        return result
    }
}
