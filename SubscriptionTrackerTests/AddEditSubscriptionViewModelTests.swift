//
//  AddEditSubscriptionViewModelTests.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest
import SwiftData
@testable import SubscriptionTracker

@MainActor
final class AddEditSubscriptionViewModelTests: XCTestCase {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Subscription.self, configurations: config)
    }

    // MARK: - Constants

    func testLayoutAndBusinessConstants() {
        XCTAssertEqual(AddEditSubscriptionViewModel.cardDigitsFieldWidth, 60)
        XCTAssertEqual(AddEditSubscriptionViewModel.maxCardDigits, 4)
        XCTAssertEqual(AddEditSubscriptionViewModel.amountFormat, "%.2f")
        XCTAssertEqual(AddEditSubscriptionViewModel.currencyCode, "USD")
    }

    // MARK: - Default Form State

    func testDefaultFormStateIsEmpty() {
        let vm = AddEditSubscriptionViewModel()
        XCTAssertEqual(vm.name, "")
        XCTAssertEqual(vm.merchant, "")
        XCTAssertEqual(vm.amountText, "")
        XCTAssertEqual(vm.billingCycle, .monthly)
        XCTAssertEqual(vm.category, .other)
        XCTAssertEqual(vm.cardLastFour, "")
        XCTAssertTrue(vm.isActive)
    }

    // MARK: - parsedAmount

    func testParsedAmountReturnsDoubleForValidInput() {
        let vm = AddEditSubscriptionViewModel()
        vm.amountText = "9.99"
        XCTAssertEqual(vm.parsedAmount, 9.99)
    }

    func testParsedAmountReturnsNilForInvalidInput() {
        let vm = AddEditSubscriptionViewModel()
        vm.amountText = "not-a-number"
        XCTAssertNil(vm.parsedAmount)
    }

    func testParsedAmountReturnsNilForEmptyInput() {
        let vm = AddEditSubscriptionViewModel()
        XCTAssertNil(vm.parsedAmount)
    }

    // MARK: - isValid

    func testIsValidTrueWhenAllRequiredFieldsAreFilled() {
        let vm = AddEditSubscriptionViewModel()
        vm.name = "Netflix"
        vm.merchant = "Netflix, Inc."
        vm.amountText = "15.99"
        XCTAssertTrue(vm.isValid)
    }

    func testIsValidFalseWhenNameIsEmpty() {
        let vm = AddEditSubscriptionViewModel()
        vm.merchant = "Netflix, Inc."
        vm.amountText = "15.99"
        XCTAssertFalse(vm.isValid)
    }

    func testIsValidFalseWhenMerchantIsEmpty() {
        let vm = AddEditSubscriptionViewModel()
        vm.name = "Netflix"
        vm.amountText = "15.99"
        XCTAssertFalse(vm.isValid)
    }

    func testIsValidFalseWhenAmountIsInvalid() {
        let vm = AddEditSubscriptionViewModel()
        vm.name = "Netflix"
        vm.merchant = "Netflix, Inc."
        vm.amountText = "bad"
        XCTAssertFalse(vm.isValid)
    }

    // MARK: - monthlyPreview

    func testMonthlyPreviewIsNilWhenAmountIsEmpty() {
        XCTAssertNil(AddEditSubscriptionViewModel().monthlyPreview)
    }

    func testMonthlyPreviewForMonthlyBillingCycle() {
        let vm = AddEditSubscriptionViewModel()
        vm.amountText = "10.00"
        vm.billingCycle = .monthly
        XCTAssertEqual(vm.monthlyPreview, 10.0, accuracy: 0.001)
    }

    func testMonthlyPreviewForWeeklyBillingCycle() {
        let vm = AddEditSubscriptionViewModel()
        vm.amountText = "10.00"
        vm.billingCycle = .weekly
        XCTAssertEqual(vm.monthlyPreview, 10.0 * BillingCycle.weeksPerMonth, accuracy: 0.001)
    }

    func testMonthlyPreviewForAnnualBillingCycle() {
        let vm = AddEditSubscriptionViewModel()
        vm.amountText = "120.00"
        vm.billingCycle = .annual
        XCTAssertEqual(vm.monthlyPreview, 10.0, accuracy: 0.001)
    }

    // MARK: - annualPreview

    func testAnnualPreviewIsNilWhenNoAmount() {
        XCTAssertNil(AddEditSubscriptionViewModel().annualPreview)
    }

    func testAnnualPreviewIsDerivedFromMonthlyPreview() {
        let vm = AddEditSubscriptionViewModel()
        vm.amountText = "10.00"
        vm.billingCycle = .monthly
        XCTAssertEqual(vm.annualPreview, 10.0 * BillingCycle.monthsPerYear, accuracy: 0.001)
    }

    // MARK: - populate(from:)

    func testPopulateFromSubscriptionFillsAllFields() {
        let renewal = date(addingDays: 10)
        let sub = makeSubscription(
            name: "Spotify",
            merchant: "Spotify AB",
            amount: 9.99,
            billingCycle: .annual,
            nextRenewal: renewal,
            category: .streaming,
            cardLastFour: "1234",
            isActive: false
        )
        let vm = AddEditSubscriptionViewModel()
        vm.populate(from: sub)

        XCTAssertEqual(vm.name, "Spotify")
        XCTAssertEqual(vm.merchant, "Spotify AB")
        XCTAssertEqual(vm.amountText, "9.99")
        XCTAssertEqual(vm.billingCycle, .annual)
        XCTAssertEqual(vm.nextRenewal, renewal)
        XCTAssertEqual(vm.category, .streaming)
        XCTAssertEqual(vm.cardLastFour, "1234")
        XCTAssertFalse(vm.isActive)
    }

    // MARK: - save(editing:context:)

    func testSaveCreatesNewSubscriptionWhenEditingIsNil() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = AddEditSubscriptionViewModel()
        vm.name = "Netflix"
        vm.merchant = "Netflix, Inc."
        vm.amountText = "15.99"
        vm.billingCycle = .monthly
        vm.category = .streaming

        vm.save(editing: nil, context: context)

        let subs = try context.fetch(FetchDescriptor<Subscription>())
        XCTAssertEqual(subs.count, 1)
        XCTAssertEqual(subs[0].name, "Netflix")
        XCTAssertEqual(subs[0].amount, 15.99, accuracy: 0.001)
    }

    func testSaveUpdatesExistingSubscriptionInPlace() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let sub = makeSubscription(name: "Old Name", amount: 9.99)
        context.insert(sub)

        let vm = AddEditSubscriptionViewModel()
        vm.populate(from: sub)
        vm.name = "New Name"
        vm.amountText = "19.99"
        vm.save(editing: sub, context: context)

        XCTAssertEqual(sub.name, "New Name")
        XCTAssertEqual(sub.amount, 19.99, accuracy: 0.001)
    }

    func testSaveDoesNothingWhenAmountIsInvalid() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = AddEditSubscriptionViewModel()
        vm.name = "Netflix"
        vm.merchant = "Netflix"
        vm.amountText = "not-a-number"

        vm.save(editing: nil, context: context)

        let subs = try context.fetch(FetchDescriptor<Subscription>())
        XCTAssertTrue(subs.isEmpty)
    }
}
