//
//  SubscriptionListViewModelTests.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest
import SwiftData
@testable import SubscriptionTracker

final class SubscriptionListViewModelTests: XCTestCase {

    private var mock: MockSubscriptionService!
    private var vm: SubscriptionListViewModel!

    override func setUp() {
        super.setUp()
        mock = MockSubscriptionService()
        vm = SubscriptionListViewModel(service: mock)
    }

    // MARK: - Layout Constants

    func testLayoutConstants() {
        XCTAssertEqual(SubscriptionListViewModel.badgeSize, 40)
        XCTAssertEqual(SubscriptionListViewModel.badgeIconSize, 16)
        XCTAssertEqual(SubscriptionListViewModel.badgeCornerRadius, 10)
        XCTAssertEqual(SubscriptionListViewModel.rowVerticalPadding, 2)
        XCTAssertEqual(SubscriptionListViewModel.rowSpacing, 12)
        XCTAssertEqual(SubscriptionListViewModel.rowTextSpacing, 2)
        XCTAssertEqual(SubscriptionListViewModel.subtitleSpacing, 4)
        XCTAssertEqual(SubscriptionListViewModel.headerSpacing, 4)
        XCTAssertEqual(SubscriptionListViewModel.headerVerticalPadding, 4)
    }

    // MARK: - Threshold Constants

    func testRenewalThresholds() {
        XCTAssertEqual(SubscriptionListViewModel.urgentDayThreshold, 1)
        XCTAssertEqual(SubscriptionListViewModel.warningDayThreshold, 3)
    }

    // MARK: - Opacity Constants

    func testOpacityConstants() {
        XCTAssertEqual(SubscriptionListViewModel.activeOpacity, 1.0)
        XCTAssertEqual(SubscriptionListViewModel.inactiveOpacity, 0.5)
    }

    // MARK: - Icon & Format Constants

    func testIconAndFormatConstants() {
        XCTAssertEqual(SubscriptionListViewModel.tabIcon, "creditcard.fill")
        XCTAssertEqual(SubscriptionListViewModel.iconAdd, "plus")
        // currencyCode is resolved from the device locale — assert it's a valid
        // 3-character ISO 4217 code rather than pinning to "USD".
        XCTAssertEqual(SubscriptionListViewModel.currencyCode.count, 3)
        XCTAssertFalse(SubscriptionListViewModel.currencyCode.isEmpty)
        XCTAssertEqual(SubscriptionListViewModel.emptyStateIcon, "creditcard.fill")
    }

    // MARK: - Delegation to Service

    func testActiveDelegatesToService() {
        let sub = makeSubscription()
        mock.stubbedActive = [sub]
        XCTAssertEqual(vm.active(in: [sub]).count, 1)
    }

    func testInactiveDelegatesToService() {
        let sub = makeSubscription(isActive: false)
        mock.stubbedInactive = [sub]
        XCTAssertEqual(vm.inactive(in: [sub]).count, 1)
    }

    func testMonthlyTotalDelegatesToService() {
        mock.stubbedMonthlyTotal = 42.0
        XCTAssertEqual(vm.monthlyTotal(in: []), 42.0)
    }

    func testAnnualTotalDelegatesToService() {
        mock.stubbedAnnualTotal = 504.0
        XCTAssertEqual(vm.annualTotal(in: []), 504.0)
    }

    func testRenewalTextDelegatesToService() {
        mock.stubbedRenewalText = "Tomorrow"
        XCTAssertEqual(vm.renewalText(for: makeSubscription()), "Tomorrow")
    }

    func testMaskedCardDelegatesToService() {
        mock.stubbedMaskedCard = "···· 4242"
        XCTAssertEqual(vm.maskedCard(lastFour: "4242"), "···· 4242")
    }

    func testRenewalColorPassesVMThresholdsToService() {
        _ = vm.renewalColor(for: makeSubscription())
        XCTAssertEqual(mock.capturedUrgentThreshold, SubscriptionListViewModel.urgentDayThreshold)
        XCTAssertEqual(mock.capturedWarningThreshold, SubscriptionListViewModel.warningDayThreshold)
    }

    @MainActor
    func testDeleteDelegatesToService() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Subscription.self, configurations: config)
        let context = ModelContext(container)
        vm.delete(from: [makeSubscription()], at: IndexSet([0]), context: context)
        XCTAssertTrue(mock.deleteCalled)
    }
}
