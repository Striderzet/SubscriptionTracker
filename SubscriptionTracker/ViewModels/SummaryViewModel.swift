//
//  SummaryViewModel.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

@Observable
final class SummaryViewModel {

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

    // MARK: - Renewal Constants
    static let upcomingWindowDays = 30
    static let urgentRenewalThreshold = 3
    static let monthsPerYear: Double = 12.0

    // MARK: - Icons
    static let tabIcon = "chart.pie.fill"

    // MARK: - Format
    static let currencyCode = "USD"
    static let tileDividerSpacing: CGFloat = 0

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
    static var chartLabelAmount: String { String(localized: "chart.label.amount") }
    static var chartLabelCategory: String { String(localized: "chart.label.category") }

    // MARK: - Data
    func active(in subscriptions: [Subscription]) -> [Subscription] {
        subscriptions.filter(\.isActive)
    }

    func monthlyTotal(in subscriptions: [Subscription]) -> Double {
        active(in: subscriptions).reduce(0) { $0 + $1.monthlyEquivalent }
    }

    func categoryData(in subscriptions: [Subscription]) -> [(category: SubscriptionCategory, total: Double)] {
        Dictionary(grouping: active(in: subscriptions), by: \.category)
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.monthlyEquivalent }) }
            .sorted { $0.total > $1.total }
    }

    func upcomingRenewals(in subscriptions: [Subscription]) -> [Subscription] {
        active(in: subscriptions)
            .filter { $0.daysUntilRenewal >= 0 && $0.daysUntilRenewal <= Self.upcomingWindowDays }
            .sorted { $0.daysUntilRenewal < $1.daysUntilRenewal }
    }

    // MARK: - Formatting
    func renewalLabel(for subscription: Subscription) -> String {
        subscription.daysUntilRenewal == 0
            ? String(localized: "renewal.today")
            : String(format: NSLocalizedString("renewal.in_days", comment: ""), subscription.daysUntilRenewal)
    }

    func isUrgent(_ subscription: Subscription) -> Bool {
        subscription.daysUntilRenewal <= Self.urgentRenewalThreshold
    }
}
