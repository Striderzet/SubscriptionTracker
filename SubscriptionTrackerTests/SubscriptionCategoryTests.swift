//
//  SubscriptionCategoryTests.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest
@testable import SubscriptionTracker

final class SubscriptionCategoryTests: XCTestCase {

    // MARK: - allCases

    func testAllCasesCount() {
        XCTAssertEqual(SubscriptionCategory.allCases.count, 7)
    }

    // MARK: - icon

    func testIconsAreNonEmpty() {
        for category in SubscriptionCategory.allCases {
            XCTAssertFalse(category.icon.isEmpty, "icon should not be empty for \(category)")
        }
    }

    func testIconsAreDistinct() {
        let icons = SubscriptionCategory.allCases.map(\.icon)
        XCTAssertEqual(Set(icons).count, icons.count, "Each category must have a unique SF Symbol name")
    }

    func testKnownIconValues() {
        XCTAssertEqual(SubscriptionCategory.streaming.icon, "play.tv.fill")
        XCTAssertEqual(SubscriptionCategory.software.icon, "laptopcomputer")
        XCTAssertEqual(SubscriptionCategory.fitness.icon, "figure.run")
        XCTAssertEqual(SubscriptionCategory.news.icon, "newspaper.fill")
        XCTAssertEqual(SubscriptionCategory.gaming.icon, "gamecontroller.fill")
        XCTAssertEqual(SubscriptionCategory.education.icon, "graduationcap.fill")
        XCTAssertEqual(SubscriptionCategory.other.icon, "square.grid.2x2.fill")
    }

    // MARK: - color

    func testColorsAreDefinedForAllCases() {
        for category in SubscriptionCategory.allCases {
            _ = category.color
        }
    }

    // MARK: - localizedName

    func testLocalizedNamesAreNonEmpty() {
        for category in SubscriptionCategory.allCases {
            XCTAssertFalse(category.localizedName.isEmpty, "localizedName should not be empty for \(category)")
        }
    }

    func testLocalizedNamesAreDistinct() {
        let names = SubscriptionCategory.allCases.map(\.localizedName)
        XCTAssertEqual(Set(names).count, names.count, "Each category must have a unique localizedName")
    }

    // MARK: - rawValue (persistence format must not change)

    func testRawValues() {
        XCTAssertEqual(SubscriptionCategory.streaming.rawValue, "Streaming")
        XCTAssertEqual(SubscriptionCategory.software.rawValue, "Software")
        XCTAssertEqual(SubscriptionCategory.fitness.rawValue, "Fitness")
        XCTAssertEqual(SubscriptionCategory.news.rawValue, "News")
        XCTAssertEqual(SubscriptionCategory.gaming.rawValue, "Gaming")
        XCTAssertEqual(SubscriptionCategory.education.rawValue, "Education")
        XCTAssertEqual(SubscriptionCategory.other.rawValue, "Other")
    }
}
