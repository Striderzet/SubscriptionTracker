//
//  SummaryViewModelTests.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest
@testable import SubscriptionTracker

final class SummaryViewModelTests: XCTestCase {

    private var mock: MockSubscriptionService!
    private var vm: SummaryViewModel!

    override func setUp() {
        super.setUp()
        mock = MockSubscriptionService()
        vm = SummaryViewModel(service: mock)
    }

    // MARK: - Chart Constants

    func testChartConstants() {
        XCTAssertEqual(SummaryViewModel.chartHeight, 200)
        XCTAssertEqual(SummaryViewModel.chartInnerRadiusRatio, 0.6, accuracy: 0.001)
        XCTAssertEqual(SummaryViewModel.chartAngularInset, 1.5, accuracy: 0.001)
        XCTAssertEqual(SummaryViewModel.chartCornerRadius, 4)
        XCTAssertEqual(SummaryViewModel.chartVerticalPadding, 8)
    }

    // MARK: - Layout Constants

    func testLayoutConstants() {
        XCTAssertEqual(SummaryViewModel.categoryIconWidth, 22)
        XCTAssertEqual(SummaryViewModel.rowSpacing, 12)
        XCTAssertEqual(SummaryViewModel.rowTextSpacing, 2)
        XCTAssertEqual(SummaryViewModel.tileVerticalPadding, 4)
        XCTAssertEqual(SummaryViewModel.tileDividerSpacing, 0)
    }

    // MARK: - Renewal Constants

    func testRenewalConstants() {
        XCTAssertEqual(SummaryViewModel.upcomingWindowDays, 30)
        XCTAssertEqual(SummaryViewModel.urgentRenewalThreshold, 3)
    }

    // MARK: - Icon & Format Constants

    func testIconAndFormatConstants() {
        XCTAssertEqual(SummaryViewModel.tabIcon, "chart.pie.fill")
        XCTAssertEqual(SummaryViewModel.currencyCode, "USD")
        XCTAssertEqual(SummaryViewModel.emptyStateIcon, "chart.pie.fill")
    }

    // MARK: - Chart Accessibility Labels

    func testChartAccessibilityLabelsAreNonEmpty() {
        XCTAssertFalse(SummaryViewModel.chartLabelAmount.isEmpty)
        XCTAssertFalse(SummaryViewModel.chartLabelCategory.isEmpty)
    }

    // MARK: - Delegation to Service

    func testMonthlyTotalDelegatesToService() {
        mock.stubbedMonthlyTotal = 99.0
        XCTAssertEqual(vm.monthlyTotal(in: []), 99.0)
    }

    func testAnnualTotalDelegatesToService() {
        mock.stubbedAnnualTotal = 1188.0
        XCTAssertEqual(vm.annualTotal(in: []), 1188.0)
    }

    func testCategoryDataDelegatesToService() {
        mock.stubbedCategoryData = [(.streaming, 20.0)]
        let result = vm.categoryData(in: [])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.category, .streaming)
    }

    func testUpcomingRenewalsPassesWindowDaysConstant() {
        _ = vm.upcomingRenewals(in: [])
        XCTAssertEqual(mock.capturedWindowDays, SummaryViewModel.upcomingWindowDays)
    }

    func testUpcomingRenewalsDelegatesToService() {
        mock.stubbedUpcomingRenewals = [makeSubscription()]
        XCTAssertEqual(vm.upcomingRenewals(in: []).count, 1)
    }

    func testRenewalLabelDelegatesToService() {
        mock.stubbedRenewalText = "Today"
        XCTAssertEqual(vm.renewalLabel(for: makeSubscription()), "Today")
    }

    // MARK: - isUrgent

    func testIsUrgentTrueWhenDaysIsZero() {
        let sub = makeSubscription(nextRenewal: startOfToday())
        XCTAssertTrue(vm.isUrgent(sub))
    }

    func testIsUrgentTrueAtExactThreshold() {
        let sub = makeSubscription(nextRenewal: date(addingDays: SummaryViewModel.urgentRenewalThreshold))
        XCTAssertTrue(vm.isUrgent(sub))
    }

    func testIsUrgentFalseWhenOneDayBeyondThreshold() {
        let sub = makeSubscription(nextRenewal: date(addingDays: SummaryViewModel.urgentRenewalThreshold + 1))
        XCTAssertFalse(vm.isUrgent(sub))
    }
}
