//
//  BillingCycleTests.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest
@testable import SubscriptionTracker

final class BillingCycleTests: XCTestCase {

    // MARK: - Constants

    func testWeeksPerMonth() {
        XCTAssertEqual(BillingCycle.weeksPerMonth, 4.33, accuracy: 0.001)
    }

    func testMonthsPerYear() {
        XCTAssertEqual(BillingCycle.monthsPerYear, 12.0)
    }

    // MARK: - allCases

    func testAllCasesCount() {
        XCTAssertEqual(BillingCycle.allCases.count, 3)
    }

    func testAllCasesContainsAllVariants() {
        XCTAssertTrue(BillingCycle.allCases.contains(.weekly))
        XCTAssertTrue(BillingCycle.allCases.contains(.monthly))
        XCTAssertTrue(BillingCycle.allCases.contains(.annual))
    }

    // MARK: - monthlyEquivalent(for:)

    func testMonthlyEquivalentWeekly() {
        XCTAssertEqual(
            BillingCycle.weekly.monthlyEquivalent(for: 10.0),
            10.0 * BillingCycle.weeksPerMonth,
            accuracy: 0.001
        )
    }

    func testMonthlyEquivalentMonthly() {
        XCTAssertEqual(BillingCycle.monthly.monthlyEquivalent(for: 10.0), 10.0)
    }

    func testMonthlyEquivalentAnnual() {
        XCTAssertEqual(BillingCycle.annual.monthlyEquivalent(for: 120.0), 10.0, accuracy: 0.001)
    }

    func testMonthlyEquivalentZeroAmountForAllCycles() {
        for cycle in BillingCycle.allCases {
            XCTAssertEqual(cycle.monthlyEquivalent(for: 0), 0, "Expected 0 for \(cycle) with zero amount")
        }
    }

    // MARK: - localizedName

    func testLocalizedNamesAreNonEmpty() {
        for cycle in BillingCycle.allCases {
            XCTAssertFalse(cycle.localizedName.isEmpty, "localizedName should not be empty for \(cycle)")
        }
    }

    func testLocalizedNamesAreDistinct() {
        let names = BillingCycle.allCases.map(\.localizedName)
        XCTAssertEqual(Set(names).count, names.count, "Each BillingCycle must have a unique localizedName")
    }

    // MARK: - rawValue (persistence format must not change)

    func testRawValues() {
        XCTAssertEqual(BillingCycle.weekly.rawValue, "Weekly")
        XCTAssertEqual(BillingCycle.monthly.rawValue, "Monthly")
        XCTAssertEqual(BillingCycle.annual.rawValue, "Annual")
    }
}
