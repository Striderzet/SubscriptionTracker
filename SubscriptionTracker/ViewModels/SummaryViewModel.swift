//
//  SummaryViewModel.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

// MARK: - Protocol (ISP / DIP)

/// The interface SummaryView depends on. Declaring this protocol
/// means a mock conformer can be injected for UI tests without SwiftData.
protocol SummaryViewModelProtocol: AnyObject {
    func monthlyTotal(in subscriptions: [Subscription]) -> Double
    func annualTotal(in subscriptions: [Subscription]) -> Double
    func categoryData(in subscriptions: [Subscription]) -> [(category: SubscriptionCategory, total: Double)]
    func upcomingRenewals(in subscriptions: [Subscription]) -> [Subscription]
    func renewalLabel(for subscription: Subscription) -> String
    func isUrgent(_ subscription: Subscription) -> Bool
}

// MARK: - Implementation

@Observable
final class SummaryViewModel: SummaryViewModelProtocol {

    // MARK: - Dependencies (DIP)
    private let service: any SubscriptionServicing

    /// Accepts any SubscriptionServicing conformer. Production code uses the default
    /// SubscriptionService(); tests can pass a mock to avoid SwiftData overhead.
    init(service: any SubscriptionServicing = SubscriptionService()) {
        self.service = service
    }

    // MARK: - Chart Constants
    static let chartHeight: CGFloat = 200
    static let chartInnerRadiusRatio: CGFloat = 0.6
    static let chartAngularInset: CGFloat = 1.5
    static let chartCornerRadius: CGFloat = 4
    static let chartVerticalPadding: CGFloat = 8

    // MARK: - Layout Constants
    static let categoryIconWidth: CGFloat = 22
    static let rowSpacing: CGFloat = 12
    static let rowTextSpacing: CGFloat = 2
    static let tileVerticalPadding: CGFloat = 4
    static let tileDividerSpacing: CGFloat = 0

    // MARK: - Renewal Constants
    static let upcomingWindowDays = 30
    static let urgentRenewalThreshold = 3

    // MARK: - Icons
    static let tabIcon = "chart.pie.fill"

    // MARK: - Format
    static let currencyCode = "USD"

    // MARK: - Strings
    static let navigationTitle: LocalizedStringKey = "summary.navigation.title"
    static let labelMonthly: LocalizedStringKey = "summary.label.monthly"
    static let labelAnnual: LocalizedStringKey = "summary.label.annual"
    static let labelPerMonth: LocalizedStringKey = "summary.label.per_month"
    static let emptyStateTitle: LocalizedStringKey = "summary.empty.title"
    static let emptyStateDescription: LocalizedStringKey = "summary.empty.description"
    static let emptyStateIcon = "chart.pie.fill"
    static let sectionCategory: LocalizedStringKey = "summary.section.category"
    static let sectionUpcoming: LocalizedStringKey = "summary.section.upcoming"

    // MARK: - Chart Accessibility Labels (runtime-localized)
    /// Swift Charts' .value() API requires String, not LocalizedStringKey.
    /// String(localized:) is used here so the label is still translated at runtime.
    static var chartLabelAmount: String { String(localized: "chart.label.amount") }
    static var chartLabelCategory: String { String(localized: "chart.label.category") }

    // MARK: - Data (delegated to service — SRP)
    func monthlyTotal(in subscriptions: [Subscription]) -> Double {
        service.monthlyTotal(in: subscriptions)
    }

    func annualTotal(in subscriptions: [Subscription]) -> Double {
        service.annualTotal(in: subscriptions)
    }

    func categoryData(in subscriptions: [Subscription]) -> [(category: SubscriptionCategory, total: Double)] {
        service.categoryData(in: subscriptions)
    }

    func upcomingRenewals(in subscriptions: [Subscription]) -> [Subscription] {
        service.upcomingRenewals(in: subscriptions, windowDays: Self.upcomingWindowDays)
    }

    // MARK: - Formatting (delegated to service — SRP)
    func renewalLabel(for subscription: Subscription) -> String {
        service.renewalText(for: subscription)
    }

    func isUrgent(_ subscription: Subscription) -> Bool {
        subscription.daysUntilRenewal <= Self.urgentRenewalThreshold
    }
}
