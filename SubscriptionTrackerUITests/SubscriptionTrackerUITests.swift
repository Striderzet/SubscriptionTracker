//
//  SubscriptionTrackerUITests.swift
//  SubscriptionTrackerUITests
//
//  Created by Tony Buckner on 9/10/26.
//

import XCTest

final class SubscriptionTrackerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // --uitesting tells the app to use an in-memory SwiftData store so each
        // test starts with a completely empty, isolated dataset.
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    // MARK: - Helpers

    /// Fills the required fields and taps Save to create one subscription.
    private func addSubscription(
        name: String = "Netflix",
        merchant: String = "Netflix, Inc.",
        amount: String = "15.99"
    ) {
        app.buttons["list.add"].tap()

        let nameField = app.textFields["Name (e.g. Netflix)"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(name)

        let merchantField = app.textFields["Merchant (e.g. Netflix, Inc.)"]
        merchantField.tap()
        merchantField.typeText(merchant)

        let amountField = app.textFields["0.00"]
        amountField.tap()
        amountField.typeText(amount)

        app.buttons["Save"].tap()
    }

    // MARK: - Launch & Tab Navigation

    func testAppLaunchesOnSubscriptionsTab() {
        XCTAssertTrue(app.navigationBars["Subscriptions"].waitForExistence(timeout: 5))
    }

    func testListEmptyStateIsVisibleOnFirstLaunch() {
        XCTAssertTrue(app.staticTexts["No Subscriptions"].waitForExistence(timeout: 3))
    }

    func testSummaryTabNavigatesSuccessfully() {
        app.tabBars.buttons["Summary"].tap()
        XCTAssertTrue(app.navigationBars["Summary"].waitForExistence(timeout: 3))
    }

    func testSummaryEmptyStateIsVisibleWithNoSubscriptions() {
        app.tabBars.buttons["Summary"].tap()
        XCTAssertTrue(app.staticTexts["No Data Yet"].waitForExistence(timeout: 3))
    }

    // MARK: - Add Subscription Sheet

    func testAddButtonOpensNewSubscriptionForm() {
        app.buttons["list.add"].tap()
        XCTAssertTrue(app.navigationBars["New Subscription"].waitForExistence(timeout: 3))
    }

    func testFormCancelButtonDismissesSheet() {
        app.buttons["list.add"].tap()
        XCTAssertTrue(app.navigationBars["New Subscription"].waitForExistence(timeout: 3))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Subscriptions"].waitForExistence(timeout: 3))
    }

    func testSaveButtonIsDisabledWithEmptyForm() {
        app.buttons["list.add"].tap()
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["Save"].isEnabled)
    }

    func testSaveButtonEnablesAfterRequiredFieldsEntered() {
        app.buttons["list.add"].tap()

        app.textFields["Name (e.g. Netflix)"].tap()
        app.textFields["Name (e.g. Netflix)"].typeText("Netflix")

        app.textFields["Merchant (e.g. Netflix, Inc.)"].tap()
        app.textFields["Merchant (e.g. Netflix, Inc.)"].typeText("Netflix, Inc.")

        app.textFields["0.00"].tap()
        app.textFields["0.00"].typeText("15.99")

        XCTAssertTrue(app.buttons["Save"].isEnabled)
    }

    func testFormShowsCostPreviewSectionWhenAmountIsEntered() {
        app.buttons["list.add"].tap()
        app.textFields["0.00"].tap()
        app.textFields["0.00"].typeText("10.00")
        XCTAssertTrue(app.staticTexts["Cost Preview"].waitForExistence(timeout: 3))
    }

    func testFormHasDetailsAndCategoryAndCardSections() {
        app.buttons["list.add"].tap()
        XCTAssertTrue(app.staticTexts["Details"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Category"].exists)
        XCTAssertTrue(app.staticTexts["Card on File"].exists)
    }

    func testFormHasBillingCycleField() {
        app.buttons["list.add"].tap()
        XCTAssertTrue(app.staticTexts["Billing Cycle"].waitForExistence(timeout: 3))
    }

    func testAddingSubscriptionAppearsInList() {
        addSubscription(name: "Netflix")
        XCTAssertTrue(app.staticTexts["Netflix"].waitForExistence(timeout: 3))
    }

    func testAddingSubscriptionDismissesFormAndReturnsToList() {
        addSubscription()
        XCTAssertTrue(app.navigationBars["Subscriptions"].waitForExistence(timeout: 3))
    }

    // MARK: - Edit Subscription Sheet

    func testTappingSubscriptionRowOpensEditForm() {
        addSubscription(name: "Spotify")
        app.staticTexts["Spotify"].tap()
        XCTAssertTrue(app.navigationBars["Edit Subscription"].waitForExistence(timeout: 3))
    }

    func testEditFormPrePopulatesSubscriptionName() {
        addSubscription(name: "Hulu")
        app.staticTexts["Hulu"].tap()

        let nameField = app.textFields["Name (e.g. Netflix)"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        XCTAssertEqual(nameField.value as? String, "Hulu")
    }

    func testEditFormShowsActiveToggle() {
        addSubscription()
        app.staticTexts["Netflix"].tap()
        XCTAssertTrue(app.switches["Active"].waitForExistence(timeout: 3))
    }

    // MARK: - Delete Subscription

    func testSwipeToDeleteRemovesSubscriptionFromList() {
        addSubscription(name: "Peacock")
        XCTAssertTrue(app.staticTexts["Peacock"].waitForExistence(timeout: 3))

        app.cells.firstMatch.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["No Subscriptions"].waitForExistence(timeout: 3))
    }

    // MARK: - Summary With Data

    func testSummaryShowsStatTilesAfterSubscriptionAdded() {
        addSubscription()
        app.tabBars.buttons["Summary"].tap()
        XCTAssertTrue(app.staticTexts["Monthly"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Annual"].exists)
    }

    func testSummaryShowsCategorySectionAfterSubscriptionAdded() {
        addSubscription()
        app.tabBars.buttons["Summary"].tap()
        XCTAssertTrue(app.staticTexts["Spending by Category"].waitForExistence(timeout: 3))
    }
}
