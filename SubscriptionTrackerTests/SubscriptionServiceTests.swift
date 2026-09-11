//
//  SubscriptionServiceTests.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest
import SwiftData
@testable import SubscriptionTracker

final class SubscriptionServiceTests: XCTestCase {

    private let service = SubscriptionService()

    // MARK: - active / inactive

    func testActiveReturnsOnlyActiveSubscriptions() {
        let result = service.active(in: [makeSubscription(isActive: true), makeSubscription(isActive: false)])
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result[0].isActive)
    }

    func testInactiveReturnsOnlyInactiveSubscriptions() {
        let result = service.inactive(in: [makeSubscription(isActive: true), makeSubscription(isActive: false)])
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result[0].isActive)
    }

    func testActiveWithEmptyListReturnsEmpty() {
        XCTAssertTrue(service.active(in: []).isEmpty)
    }

    func testInactiveWithEmptyListReturnsEmpty() {
        XCTAssertTrue(service.inactive(in: []).isEmpty)
    }

    // MARK: - monthlyTotal

    func testMonthlyTotalExcludesInactiveSubscriptions() {
        let result = service.monthlyTotal(in: [
            makeSubscription(amount: 10.0, isActive: true),
            makeSubscription(amount: 50.0, isActive: false)
        ])
        XCTAssertEqual(result, 10.0, accuracy: 0.001)
    }

    func testMonthlyTotalSumsAllActiveSubscriptions() {
        let result = service.monthlyTotal(in: [makeSubscription(amount: 10.0), makeSubscription(amount: 5.0)])
        XCTAssertEqual(result, 15.0, accuracy: 0.001)
    }

    func testMonthlyTotalOfEmptyListIsZero() {
        XCTAssertEqual(service.monthlyTotal(in: []), 0)
    }

    // MARK: - annualTotal

    func testAnnualTotalIsMonthlyTimesMonthsPerYear() {
        let subs = [makeSubscription(amount: 10.0)]
        let monthly = service.monthlyTotal(in: subs)
        XCTAssertEqual(service.annualTotal(in: subs), monthly * BillingCycle.monthsPerYear, accuracy: 0.001)
    }

    // MARK: - categoryData

    func testCategoryDataGroupsSubscriptionsByCategory() {
        let result = service.categoryData(in: [
            makeSubscription(amount: 10.0, category: .streaming),
            makeSubscription(amount: 5.0, category: .streaming),
            makeSubscription(amount: 20.0, category: .gaming)
        ])
        XCTAssertEqual(result.count, 2)
    }

    func testCategoryDataSumsAmountsWithinEachGroup() {
        let result = service.categoryData(in: [
            makeSubscription(amount: 10.0, category: .streaming),
            makeSubscription(amount: 5.0, category: .streaming)
        ])
        XCTAssertEqual(result.first?.total, 15.0, accuracy: 0.001)
    }

    func testCategoryDataSortsByTotalDescending() {
        let result = service.categoryData(in: [
            makeSubscription(amount: 5.0, category: .gaming),
            makeSubscription(amount: 100.0, category: .streaming)
        ])
        XCTAssertEqual(result.first?.category, .streaming)
    }

    func testCategoryDataExcludesInactiveSubscriptions() {
        let result = service.categoryData(in: [
            makeSubscription(amount: 10.0, category: .streaming, isActive: true),
            makeSubscription(amount: 50.0, category: .gaming, isActive: false)
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.category, .streaming)
    }

    func testCategoryDataReturnsEmptyForEmptyInput() {
        XCTAssertTrue(service.categoryData(in: []).isEmpty)
    }

    // MARK: - upcomingRenewals

    func testUpcomingRenewalsIncludesRenewalWithinWindow() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 15))
        XCTAssertEqual(service.upcomingRenewals(in: [sub], windowDays: 30).count, 1)
    }

    func testUpcomingRenewalsIncludesRenewalToday() {
        let sub = makeSubscription(nextRenewal: startOfToday())
        XCTAssertEqual(service.upcomingRenewals(in: [sub], windowDays: 30).count, 1)
    }

    func testUpcomingRenewalsExcludesRenewalBeyondWindow() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 31))
        XCTAssertTrue(service.upcomingRenewals(in: [sub], windowDays: 30).isEmpty)
    }

    func testUpcomingRenewalsExcludesOverdueSubscriptions() {
        let sub = makeSubscription(nextRenewal: date(addingDays: -1))
        XCTAssertTrue(service.upcomingRenewals(in: [sub], windowDays: 30).isEmpty)
    }

    func testUpcomingRenewalsExcludesInactiveSubscriptions() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 5), isActive: false)
        XCTAssertTrue(service.upcomingRenewals(in: [sub], windowDays: 30).isEmpty)
    }

    func testUpcomingRenewalsSortsByDaysAscending() {
        let sooner = makeSubscription(nextRenewal: date(addingDays: 3))
        let later = makeSubscription(nextRenewal: date(addingDays: 10))
        let result = service.upcomingRenewals(in: [later, sooner], windowDays: 30)
        XCTAssertEqual(result.first?.daysUntilRenewal, 3)
    }

    // MARK: - renewalText

    func testRenewalTextOverdueIsNonEmpty() {
        let sub = makeSubscription(nextRenewal: date(addingDays: -1))
        XCTAssertFalse(service.renewalText(for: sub).isEmpty)
    }

    func testRenewalTextTodayIsNonEmpty() {
        let sub = makeSubscription(nextRenewal: startOfToday())
        XCTAssertFalse(service.renewalText(for: sub).isEmpty)
    }

    func testRenewalTextTomorrowIsNonEmpty() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 1))
        XCTAssertFalse(service.renewalText(for: sub).isEmpty)
    }

    func testRenewalTextFutureContainsDayCount() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 7))
        XCTAssertTrue(service.renewalText(for: sub).contains("7"))
    }

    // MARK: - renewalColor

    func testRenewalColorIsRedWhenDaysIsLessThanUrgentThreshold() {
        // 0 days < urgentThreshold 1 → .red
        let sub = makeSubscription(nextRenewal: startOfToday())
        XCTAssertEqual(service.renewalColor(for: sub, urgentThreshold: 1, warningThreshold: 3), .red)
    }

    func testRenewalColorIsOrangeWhenDaysIsWithinWarningRange() {
        // 2 days falls in urgentThreshold...warningThreshold (1...3) → .orange
        let sub = makeSubscription(nextRenewal: date(addingDays: 2))
        XCTAssertEqual(service.renewalColor(for: sub, urgentThreshold: 1, warningThreshold: 3), .orange)
    }

    func testRenewalColorIsSecondaryWhenDaysExceedsWarningThreshold() {
        let sub = makeSubscription(nextRenewal: date(addingDays: 10))
        XCTAssertEqual(service.renewalColor(for: sub, urgentThreshold: 1, warningThreshold: 3), .secondary)
    }

    // MARK: - maskedCard

    func testMaskedCardFormatsWithBullets() {
        XCTAssertEqual(service.maskedCard(lastFour: "1234"), "···· 1234")
    }

    func testMaskedCardWorksWithAnyDigits() {
        XCTAssertEqual(service.maskedCard(lastFour: "9999"), "···· 9999")
    }

    // MARK: - delete

    @MainActor
    func testDeleteRemovesSubscriptionFromContext() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Subscription.self, configurations: config)
        let context = ModelContext(container)
        let sub = makeSubscription()
        context.insert(sub)
        try context.save()

        service.delete(from: [sub], at: IndexSet([0]), context: context)

        let remaining = try context.fetch(FetchDescriptor<Subscription>())
        XCTAssertEqual(remaining.count, 0)
    }
}
