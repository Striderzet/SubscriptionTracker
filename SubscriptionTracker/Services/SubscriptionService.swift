//
//  SubscriptionService.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

// MARK: - Protocol (ISP / DIP)

/// The abstraction that ViewModels depend on for all subscription business operations.
/// Declaring dependencies against this protocol (not the concrete type) means tests can
/// inject a mock conformer without touching production code.
protocol SubscriptionServicing {
    func active(in subscriptions: [Subscription]) -> [Subscription]
    func inactive(in subscriptions: [Subscription]) -> [Subscription]
    func monthlyTotal(in subscriptions: [Subscription]) -> Double
    func annualTotal(in subscriptions: [Subscription]) -> Double
    func categoryData(in subscriptions: [Subscription]) -> [(category: SubscriptionCategory, total: Double)]
    func upcomingRenewals(in subscriptions: [Subscription], windowDays: Int) -> [Subscription]
    func renewalText(for subscription: Subscription) -> String
    func renewalColor(for subscription: Subscription, urgentThreshold: Int, warningThreshold: Int) -> Color
    func maskedCard(lastFour: String) -> String
    func delete(from list: [Subscription], at offsets: IndexSet, context: ModelContext)
}

// MARK: - Concrete Implementation (SRP)

/// Default SubscriptionServicing implementation. All shared business logic lives here
/// so it is not duplicated across the List and Summary ViewModels.
struct SubscriptionService: SubscriptionServicing {

    func active(in subscriptions: [Subscription]) -> [Subscription] {
        subscriptions.filter(\.isActive)
    }

    func inactive(in subscriptions: [Subscription]) -> [Subscription] {
        subscriptions.filter { !$0.isActive }
    }

    func monthlyTotal(in subscriptions: [Subscription]) -> Double {
        active(in: subscriptions).reduce(0) { $0 + $1.monthlyEquivalent }
    }

    func annualTotal(in subscriptions: [Subscription]) -> Double {
        monthlyTotal(in: subscriptions) * BillingCycle.monthsPerYear
    }

    func categoryData(in subscriptions: [Subscription]) -> [(category: SubscriptionCategory, total: Double)] {
        // Group active subscriptions by category, sum each group's monthly spend,
        // then sort descending so the highest-spend category leads in the chart.
        Dictionary(grouping: active(in: subscriptions), by: \.category)
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.monthlyEquivalent }) }
            .sorted { $0.total > $1.total }
    }

    func upcomingRenewals(in subscriptions: [Subscription], windowDays: Int) -> [Subscription] {
        // >= 0 intentionally excludes overdue subscriptions (negative daysUntilRenewal).
        active(in: subscriptions)
            .filter { $0.daysUntilRenewal >= 0 && $0.daysUntilRenewal <= windowDays }
            .sorted { $0.daysUntilRenewal < $1.daysUntilRenewal }
    }

    func renewalText(for subscription: Subscription) -> String {
        switch subscription.daysUntilRenewal {
        case ..<0: return String(localized: "renewal.overdue")
        case 0:    return String(localized: "renewal.today")
        case 1:    return String(localized: "renewal.tomorrow")
        default:   return String(format: String(localized: "renewal.in_days"), subscription.daysUntilRenewal)
        }
    }

    func renewalColor(for subscription: Subscription, urgentThreshold: Int, warningThreshold: Int) -> Color {
        switch subscription.daysUntilRenewal {
        case ..<urgentThreshold:                   return .red
        case urgentThreshold...warningThreshold:   return .orange
        default:                                   return .secondary
        }
    }

    func maskedCard(lastFour: String) -> String {
        "···· \(lastFour)"
    }

    func delete(from list: [Subscription], at offsets: IndexSet, context: ModelContext) {
        offsets.forEach { context.delete(list[$0]) }
    }
}
