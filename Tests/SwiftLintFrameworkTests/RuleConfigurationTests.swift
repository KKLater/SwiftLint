//
//  RuleConfigurationTests.swift
//  SwiftLint
//
//  Created by Scott Hoyt on 1/20/16.
//  Copyright © 2016 Realm. All rights reserved.
//

import SourceKittenFramework
@testable import SwiftLintFramework
import XCTest

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class RuleConfigurationsTests: XCTestCase {

    func testLineLengthConfigurationInitializerSetsLength() {
        let warning = 100
        let error = 150
        let length1 = SeverityLevelsConfiguration(warning: warning, error: error)
        let configuration1 = LineLengthConfiguration(warning: warning, error: error, ignoresURLs: true)
        XCTAssertEqual(configuration1.length, length1)

        let length2 = SeverityLevelsConfiguration(warning: warning, error: nil)
        let configuration2 = LineLengthConfiguration(warning: warning, error: nil, ignoresURLs: true)
        XCTAssertEqual(configuration2.length, length2)
    }

    func testLineLengthConfigurationInitialiserSetsIgnoresUrls() {
        let configuration1 = LineLengthConfiguration(warning: 100, error: 150, ignoresURLs: true)
        XCTAssertTrue(configuration1.ignoresURLs)

        let configuration2 = LineLengthConfiguration(warning: 100, error: 150, ignoresURLs: false)
        XCTAssertFalse(configuration2.ignoresURLs)
    }

    func testLineLengthConfigurationParams() {
        let warning = 13
        let error = 10
        let configuration = LineLengthConfiguration(warning: warning, error: error, ignoresURLs: true)
        let params = [RuleParameter(severity: .error, value: error), RuleParameter(severity: .warning, value: warning)]
        XCTAssertEqual(configuration.params, params)
    }

    func testLineLengthConfigurationPartialParams() {
        let warning = 13
        let configuration = LineLengthConfiguration(warning: warning, error: nil, ignoresURLs: true)
        XCTAssertEqual(configuration.params, [RuleParameter(severity: .warning, value: 13)])
    }

    func testLineLengthConfigurationThrowsOnBadConfig() {
        let config = "unknown"
        var configuration = LineLengthConfiguration(warning: 100, error: 150, ignoresURLs: true)

        checkError(ConfigurationError.unknownConfiguration) {
            try configuration.applyConfiguration(config)
        }
    }

    func testLineLengthConfigurationApplyConfigurationWithArray() {
        var configuration = LineLengthConfiguration(warning: 0, error: 0, ignoresURLs: false)

        let warning1 = 100
        let error1 = 100
        let length1 = SeverityLevelsConfiguration(warning: warning1, error: error1)
        let config1 = [warning1, error1]

        let warning2 = 150
        let length2 = SeverityLevelsConfiguration(warning: warning2, error: nil)
        let config2 = [warning2]

        do {
            try configuration.applyConfiguration(config1)
            XCTAssertEqual(configuration.length, length1)

            try configuration.applyConfiguration(config2)
            XCTAssertEqual(configuration.length, length2)
        } catch {
            XCTFail()
        }
    }

    func testLineLengthConfigurationApplyConfigurationWithDictionary() {
        var configuration = LineLengthConfiguration(warning: 0, error: 0, ignoresURLs: false)

        let warning1 = 100
        let error1 = 100
        let length1 = SeverityLevelsConfiguration(warning: warning1, error: error1)
        let config1: [String: Any] = ["warning": warning1, "error": error1, "ignores_urls": true]

        let warning2 = 200
        let error2 = 200
        let length2 = SeverityLevelsConfiguration(warning: warning2, error: error2)
        let config2: [String: Int] = ["warning": warning2, "error": error2]

        let length3 = SeverityLevelsConfiguration(warning: warning2, error: nil)
        let config3: [String: Bool] = ["ignores_urls": false]

        do {
            try configuration.applyConfiguration(config1)
            XCTAssertEqual(configuration.length, length1)
            XCTAssertTrue(configuration.ignoresURLs)

            try configuration.applyConfiguration(config2)
            XCTAssertEqual(configuration.length, length2)
            XCTAssertTrue(configuration.ignoresURLs)

            try configuration.applyConfiguration(config3)
            XCTAssertEqual(configuration.length, length3)
            XCTAssertFalse(configuration.ignoresURLs)
        } catch {
            XCTFail()
        }
    }

    func testLineLengthConfigurationCompares() {
        let configuration1 = LineLengthConfiguration(warning: 100, error: 100, ignoresURLs: true)
        let configuration2 = LineLengthConfiguration(warning: 100, error: 100, ignoresURLs: false)
        XCTAssertFalse(configuration1 == configuration2)

        let configuration3 = LineLengthConfiguration(warning: 100, error: 200, ignoresURLs: true)
        XCTAssertFalse(configuration1 == configuration3)

        let configuration4 = LineLengthConfiguration(warning: 200, error: 100, ignoresURLs: true)
        XCTAssertFalse(configuration1 == configuration4)

        let configuration5 = LineLengthConfiguration(warning: 100, error: 100, ignoresURLs: true)
        XCTAssertTrue(configuration1 == configuration5)

        let configuration6 = LineLengthConfiguration(warning: 100, error: 100, ignoresURLs: false)
        XCTAssertTrue(configuration2 == configuration6)
    }

    func testNameConfigurationSetsCorrectly() {
        let config = [ "min_length": ["warning": 17, "error": 7],
                       "max_length": ["warning": 170, "error": 700],
                       "excluded": "id"] as [String : Any]
        var nameConfig = NameConfiguration(minLengthWarning: 0,
                                           minLengthError: 0,
                                           maxLengthWarning: 0,
                                           maxLengthError: 0)
        let comp = NameConfiguration(minLengthWarning: 17,
                                     minLengthError: 7,
                                     maxLengthWarning: 170,
                                     maxLengthError: 700,
                                     excluded: ["id"])
        do {
            try nameConfig.applyConfiguration(config)
            XCTAssertEqual(nameConfig, comp)
        } catch {
            XCTFail("Did not configure correctly")
        }
    }

    func testNameConfigurationThrowsOnBadConfig() {
        let config = 17
        var nameConfig = NameConfiguration(minLengthWarning: 0,
                                           minLengthError: 0,
                                           maxLengthWarning: 0,
                                           maxLengthError: 0)
        checkError(ConfigurationError.unknownConfiguration) {
            try nameConfig.applyConfiguration(config)
        }
    }

    func testNameConfigurationMinLengthThreshold() {
        var nameConfig = NameConfiguration(minLengthWarning: 7,
                                           minLengthError: 17,
                                           maxLengthWarning: 0,
                                           maxLengthError: 0,
                                           excluded: [])
        XCTAssertEqual(nameConfig.minLengthThreshold, 17)

        nameConfig.minLength.error = nil
        XCTAssertEqual(nameConfig.minLengthThreshold, 7)
    }

    func testNameConfigurationMaxLengthThreshold() {
        var nameConfig = NameConfiguration(minLengthWarning: 0,
                                           minLengthError: 0,
                                           maxLengthWarning: 17,
                                           maxLengthError: 7,
                                           excluded: [])
        XCTAssertEqual(nameConfig.maxLengthThreshold, 7)

        nameConfig.maxLength.error = nil
        XCTAssertEqual(nameConfig.maxLengthThreshold, 17)
    }

    func testSeverityConfigurationFromString() {
        let config = "Warning"
        let comp = SeverityConfiguration(.warning)
        var severityConfig = SeverityConfiguration(.error)
        do {
            try severityConfig.applyConfiguration(config)
            XCTAssertEqual(severityConfig, comp)
        } catch {
            XCTFail()
        }
    }

    func testSeverityConfigurationFromDictionary() {
        let config = ["severity": "warning"]
        let comp = SeverityConfiguration(.warning)
        var severityConfig = SeverityConfiguration(.error)
        do {
            try severityConfig.applyConfiguration(config)
            XCTAssertEqual(severityConfig, comp)
        } catch {
            XCTFail()
        }
    }

    func testSeverityConfigurationThrowsOnBadConfig() {
        let config = 17
        var severityConfig = SeverityConfiguration(.warning)
        checkError(ConfigurationError.unknownConfiguration) {
            try severityConfig.applyConfiguration(config)
        }
    }

    func testSeverityLevelConfigParams() {
        let severityConfig = SeverityLevelsConfiguration(warning: 17, error: 7)
        XCTAssertEqual(severityConfig.params, [RuleParameter(severity: .error, value: 7),
            RuleParameter(severity: .warning, value: 17)])
    }

    func testSeverityLevelConfigPartialParams() {
        let severityConfig = SeverityLevelsConfiguration(warning: 17, error: nil)
        XCTAssertEqual(severityConfig.params, [RuleParameter(severity: .warning, value: 17)])
    }

    func testRegexConfigurationThrows() {
        let config = 17
        var regexConfig = RegexConfiguration(identifier: "")
        checkError(ConfigurationError.unknownConfiguration) {
            try regexConfig.applyConfiguration(config)
        }
    }

    func testRegexRuleDescription() {
        var regexConfig = RegexConfiguration(identifier: "regex")
        XCTAssertEqual(regexConfig.description, RuleDescription(identifier: "regex",
                                                                name: "regex",
                                                                description: ""))
        regexConfig.name = "name"
        XCTAssertEqual(regexConfig.description, RuleDescription(identifier: "regex",
                                                                name: "name",
                                                                description: ""))
    }

    func testTrailingWhitespaceConfigurationThrowsOnBadConfig() {
        let config = "unknown"
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        checkError(ConfigurationError.unknownConfiguration) {
            try configuration.applyConfiguration(config)
        }
    }

    func testTrailingWhitespaceConfigurationInitializerSetsIgnoresEmptyLines() {
        let configuration1 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: true)
        XCTAssertFalse(configuration1.ignoresEmptyLines)

        let configuration2 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: true)
        XCTAssertTrue(configuration2.ignoresEmptyLines)
    }

    func testTrailingWhitespaceConfigurationInitializerSetsIgnoresComments() {
        let configuration1 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: true)
        XCTAssertTrue(configuration1.ignoresComments)

        let configuration2 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: false)
        XCTAssertFalse(configuration2.ignoresComments)
    }

    func testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresEmptyLines() {
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        do {
            let config1 = ["ignores_empty_lines": true]
            try configuration.applyConfiguration(config1)
            XCTAssertTrue(configuration.ignoresEmptyLines)

            let config2 = ["ignores_empty_lines": false]
            try configuration.applyConfiguration(config2)
            XCTAssertFalse(configuration.ignoresEmptyLines)
        } catch {
            XCTFail()
        }
    }

    func testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresComments() {
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        do {
            let config1 = ["ignores_comments": true]
            try configuration.applyConfiguration(config1)
            XCTAssertTrue(configuration.ignoresComments)

            let config2 = ["ignores_comments": false]
            try configuration.applyConfiguration(config2)
            XCTAssertFalse(configuration.ignoresComments)
        } catch {
            XCTFail()
        }
    }

    func testTrailingWhitespaceConfigurationCompares() {
        let configuration1 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: true)
        let configuration2 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: true)
        XCTAssertFalse(configuration1 == configuration2)

        let configuration3 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: true)
        XCTAssertTrue(configuration2 == configuration3)

        let configuration4 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: false)

        XCTAssertFalse(configuration1 == configuration4)

        let configuration5 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: false)

        XCTAssertFalse(configuration1 == configuration5)
    }

    func testTrailingWhitespaceConfigurationApplyConfigurationUpdatesSeverityConfiguration() {
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        configuration.severityConfiguration.severity = .warning

        do {
            try configuration.applyConfiguration(["severity": "error"])
            XCTAssert(configuration.severityConfiguration.severity == .error)
        } catch {
            XCTFail()
        }
    }

    func testOverridenSuperCallConfigurationFromDictionary() {
        var configuration = OverridenSuperCallConfiguration()
        XCTAssertTrue(configuration.resolvedMethodNames.contains("viewWillAppear(_:)"))

        let conf1 = ["severity": "error", "excluded": "viewWillAppear(_:)"]
        do {
            try configuration.applyConfiguration(conf1)
            XCTAssert(configuration.severityConfiguration.severity == .error)
            XCTAssertFalse(configuration.resolvedMethodNames.contains("*"))
            XCTAssertFalse(configuration.resolvedMethodNames.contains("viewWillAppear(_:)"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("viewWillDisappear(_:)"))
        } catch {
            XCTFail()
        }

        let conf2 = [
            "severity": "error",
            "excluded": "viewWillAppear(_:)",
            "included": ["*", "testMethod1()", "testMethod2(_:)"]
        ] as [String : Any]
        do {
            try configuration.applyConfiguration(conf2)
            XCTAssert(configuration.severityConfiguration.severity == .error)
            XCTAssertFalse(configuration.resolvedMethodNames.contains("*"))
            XCTAssertFalse(configuration.resolvedMethodNames.contains("viewWillAppear(_:)"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("viewWillDisappear(_:)"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod1()"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod2(_:)"))
        } catch {
            XCTFail()
        }

        let conf3 = [
            "severity": "warning",
            "excluded": "*",
            "included": ["testMethod1()", "testMethod2(_:)"]
        ] as [String : Any]
        do {
            try configuration.applyConfiguration(conf3)
            XCTAssert(configuration.severityConfiguration.severity == .warning)
            XCTAssert(configuration.resolvedMethodNames.count == 2)
            XCTAssertFalse(configuration.resolvedMethodNames.contains("*"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod1()"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod2(_:)"))
        } catch {
            XCTFail()
        }
    }
}

extension RuleConfigurationsTests {
    static var allTests: [(String, (RuleConfigurationsTests) -> () throws -> Void)] {
        return [
            ("testLineLengthConfigurationInitializerSetsLength",
                testLineLengthConfigurationParams),
            ("testLineLengthConfigurationInitialiserSetsIgnoresUrls",
                testLineLengthConfigurationInitialiserSetsIgnoresUrls),
            ("testLineLengthConfigurationPartialParams",
                testLineLengthConfigurationPartialParams),
            ("testLineLengthConfigurationParams",
                testLineLengthConfigurationParams),
            ("testLineLengthConfigurationThrowsOnBadConfig",
                testLineLengthConfigurationThrowsOnBadConfig),
            ("testLineLengthConfigurationApplyConfigurationWithArray",
                testLineLengthConfigurationApplyConfigurationWithArray),
            ("testLineLengthConfigurationApplyConfigurationWithDictionary",
                testLineLengthConfigurationApplyConfigurationWithDictionary),
            ("testLineLengthConfigurationCompares",
                testLineLengthConfigurationCompares),
            ("testNameConfigurationSetsCorrectly",
                testNameConfigurationSetsCorrectly),
            ("testNameConfigurationThrowsOnBadConfig",
                testNameConfigurationThrowsOnBadConfig),
            ("testNameConfigurationMinLengthThreshold",
                testNameConfigurationMinLengthThreshold),
            ("testNameConfigurationMaxLengthThreshold",
                testNameConfigurationMaxLengthThreshold),
            ("testSeverityConfigurationFromString",
                testSeverityConfigurationFromString),
            ("testSeverityConfigurationFromDictionary",
                testSeverityConfigurationFromDictionary),
            ("testSeverityConfigurationThrowsOnBadConfig",
                testSeverityConfigurationThrowsOnBadConfig),
            ("testSeverityLevelConfigParams",
                testSeverityLevelConfigParams),
            ("testSeverityLevelConfigPartialParams",
                testSeverityLevelConfigPartialParams),
            ("testRegexConfigurationThrows",
                testRegexConfigurationThrows),
            ("testRegexRuleDescription",
                testRegexRuleDescription),
            ("testTrailingWhitespaceConfigurationThrowsOnBadConfig",
                testTrailingWhitespaceConfigurationThrowsOnBadConfig),
            ("testTrailingWhitespaceConfigurationInitializerSetsIgnoresEmptyLines",
                testTrailingWhitespaceConfigurationInitializerSetsIgnoresEmptyLines),
            ("testTrailingWhitespaceConfigurationInitializerSetsIgnoresComments",
                testTrailingWhitespaceConfigurationInitializerSetsIgnoresComments),
            ("testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresEmptyLines",
                testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresEmptyLines),
            ("testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresComments",
                testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresComments),
            ("testTrailingWhitespaceConfigurationCompares",
                testTrailingWhitespaceConfigurationCompares),
            ("testTrailingWhitespaceConfigurationApplyConfigurationUpdatesSeverityConfiguration",
                testTrailingWhitespaceConfigurationApplyConfigurationUpdatesSeverityConfiguration),
            ("testOverridenSuperCallConfigurationFromDictionary",
                testOverridenSuperCallConfigurationFromDictionary)
        ]
    }
}
