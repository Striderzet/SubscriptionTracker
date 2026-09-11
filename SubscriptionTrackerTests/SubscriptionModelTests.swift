//
//  SubscriptionModelTests.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest
@testable import SubscriptionTracker

final class SubscriptionModelTests: XCTestCase {

    // MARK: - monthlyEquivalent

    func testMonthlyEquivalentDelegatesToBillingCycle() {
        let sub = makeSubscription(amount: 12.0, billingCycle: .annual)
        XCTAssertEqual(sub.monthlyEquivalent, BillingCycle.annual.monthlyEquivalent(for: 12.0), accuracy: 0.001)
    }

    func testMonthlyEquivalentWeekly() {
        let sub = makeSubscription(amount: 10.0, billingCycle: .weekly)
        XCTAssertEqual(sub.monthlyEquivalent, 10.0 * BillingCycle.weeksPerMonth, accuracy: 0.001)
    }

    func testMonthlyEquivalentMonthly() {
        let sub = makeSubscription(amount: 9.99, billingCycle: .monthly)
        XCTAssertEqual(sub.monthlyEquivalent, 9.99, accuracy: 0.001)
    }

    func testMonthlyEquivalentAnnual() {
        let sub = makeSubscription(amount: 120.0, billingCycle: .annual)
        XCTAssertEqual(sub.monthlyEquivalent, 10.0, accuracy: 0.001)
    }

    // MARK: - daysUntilRenewal

    func testDaysUntilRenewalIsZeroForToday() {
        let sub = makeSubscription(nextRenewal: startOfToday())
        XCTAssertEqual(sub.daysUntilRenewal, 0)
    }

    func testDaysUntilRenewalIsOneForTomorrow() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 1))
        XCTAssertEqual(sub.daysUntilRenewal, 1)
    }

    func testDaysUntilRenewalIsNegativeForOverdue() {
        let sub = makeSubscription(nextRenewal: date(addingDays: -1))
        XCTAssertEqual(sub.daysUntilRenewal, -1)
    }

    func testDaysUntilRenewalFuture() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 14))
        XCTAssertEqual(sub.daysUntilRenewal, 14)
    }

    // MARK: - init defaults

    func testDefaultIsActiveTrue() {
        let sub = makeSubscription()
        XCTAssertTrue(sub.isActive)
    }

    func testDefaultCardLastFourIsEmpty() {
        let sub = makeSubscription()
        XCTAssertEqual(sub.cardLastFour, "")
    }

    func testCreatedAtIsSetToNow() {
        let before = Date()
        let sub = makeSubscription()
        let after = Date()
        XCTAssertGreaterThanOrEqual(sub.createdAt, before)
        XCTAssertLessThanOrEqual(sub.createdAt, after)
    }

    func testCustomValuesAreStoredCorrectly() {
        let renewal = date(addingDays: 7)
        let sub = makeSubscription(
            name: "Spotify",
            merchant: "Spotify AB",
            amount: 9.99,
            billingCycle: .annual,
            nextRenewal: renewal,
            category: .streaming,
            cardLastFour: "4321",
            isActive: false
        )
        XCTAssertEqual(sub.name, "Spotify")
        XCTAssertEqual(sub.merchant, "Spotify AB")
        XCTAssertEqual(sub.amount, 9.99)
        XCTAssertEqual(sub.billingCycle, .annual)
        XCTAssertEqual(sub.nextRenewal, renewal)
        XCTAssertEqual(sub.category, .streaming)
        XCTAssertEqual(sub.cardLastFour, "4321")
        XCTAssertFalse(sub.isActive)
    }
}
