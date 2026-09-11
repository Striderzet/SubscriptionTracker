//
//  MockSubscriptionService.swift
//  SubscriptionTrackerTests
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData
@testable import SubscriptionTracker

/// Configurable test double for SubscriptionServicing. Set stub properties before
/// calling a VM method, then inspect call-tracking properties for side-effect assertions.
final class MockSubscriptionService: SubscriptionServicing {

    // MARK: - Stubs
    var stubbedActive: [Subscription] = []
    var stubbedInactive: [Subscription] = []
    var stubbedMonthlyTotal: Double = 0
    var stubbedAnnualTotal: Double = 0
    var stubbedCategoryData: [(category: SubscriptionCategory, total: Double)] = []
    var stubbedUpcomingRenewals: [Subscription] = []
    var stubbedRenewalText: String = ""
    var stubbedRenewalColor: Color = .secondary
    var stubbedMaskedCard: String = ""

    // MARK: - Call Tracking
    var deleteCalled = false
    var capturedUrgentThreshold = 0
    var capturedWarningThreshold = 0
    var capturedWindowDays = 0

    func active(in subscriptions: [Subscription]) -> [Subscription] { stubbedActive }
    func inactive(in subscriptions: [Subscription]) -> [Subscription] { stubbedInactive }
    func monthlyTotal(in subscriptions: [Subscription]) -> Double { stubbedMonthlyTotal }
    func annualTotal(in subscriptions: [Subscription]) -> Double { stubbedAnnualTotal }

    func categoryData(in subscriptions: [Subscription]) -> [(category: SubscriptionCategory, total: Double)] {
        stubbedCategoryData
    }

    func upcomingRenewals(in subscriptions: [Subscription], windowDays: Int) -> [Subscription] {
        capturedWindowDays = windowDays
        return stubbedUpcomingRenewals
    }

    func renewalText(for subscription: Subscription) -> String { stubbedRenewalText }

    func renewalColor(for subscription: Subscription, urgentThreshold: Int, warningThreshold: Int) -> Color {
        capturedUrgentThreshold = urgentThreshold
        capturedWarningThreshold = warningThreshold
        return stubbedRenewalColor
    }

    func maskedCard(lastFour: String) -> String { stubbedMaskedCard }

    func delete(from list: [Subscription], at offsets: IndexSet, context: ModelContext) {
        deleteCalled = true
    }
}

// MARK: - Shared Test Helpers

/// Creates a Subscription with sensible defaults so each test only specifies what it cares about.
func makeSubscription(
    name: String = "Test Sub",
    merchant: String = "Test Co.",
    amount: Double = 9.99,
    billingCycle: BillingCycle = .monthly,
    nextRenewal: Date? = nil,
    category: SubscriptionCategory = .other,
    cardLastFour: String = "",
    isActive: Bool = true
) -> Subscription {
    Subscription(
        name: name,
        merchant: merchant,
        amount: amount,
        billingCycle: billingCycle,
        nextRenewal: nextRenewal ?? Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
        category: category,
        cardLastFour: cardLastFour,
        isActive: isActive
    )
}

func startOfToday() -> Date {
    Calendar.current.startOfDay(for: Date())
}

func date(addingDays days: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: days, to: startOfToday())!
}
