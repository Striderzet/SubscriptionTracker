//
//  SubscriptionListViewModel.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

@Observable
final class SubscriptionListViewModel {

    // MARK: - Layout Constants
    static let badgeSize: CGFloat = 40
    static let badgeIconSize: CGFloat = 16
    static let badgeCornerRadius: CGFloat = 10
    static let rowVerticalPadding: CGFloat = 2
    static let rowSpacing: CGFloat = 12
    static let rowTextSpacing: CGFloat = 2
    static let subtitleSpacing: CGFloat = 4
    static let headerSpacing: CGFloat = 4
    static let headerVerticalPadding: CGFloat = 4

    // MARK: - Renewal Thresholds
    static let urgentDayThreshold = 1
    static let warningDayThreshold = 3

    // MARK: - Opacity
    static let activeOpacity: Double = 1.0
    static let inactiveOpacity: Double = 0.5

    // MARK: - Icons
    static let tabIcon = "creditcard.fill"
    static let iconAdd = "plus"

    // MARK: - Format
    static let currencyCode = "USD"

    // MARK: - Strings
    static let navigationTitle: LocalizedStringKey = "Subscriptions"
    static let labelMonthlyTotal: LocalizedStringKey = "Monthly Total"
    static let labelAnnual: LocalizedStringKey = "Annual"
    static let separatorDot: LocalizedStringKey = "·"
    static let emptyStateTitle: LocalizedStringKey = "list.empty.title"
    static let emptyStateDescription: LocalizedStringKey = "list.empty.description"
    static let emptyStateIcon = "creditcard.fill"
    static let sectionActive: LocalizedStringKey = "list.section.active"
    static let sectionInactive: LocalizedStringKey = "list.section.inactive"

    // MARK: - Data
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
        monthlyTotal(in: subscriptions) * 12.0
    }

    func delete(from list: [Subscription], at offsets: IndexSet, context: ModelContext) {
        offsets.forEach { context.delete(list[$0]) }
    }

    // MARK: - Formatting
    func renewalText(for subscription: Subscription) -> String {
        switch subscription.daysUntilRenewal {
        case ..<0: return String(localized: "renewal.overdue")
        case 0:    return String(localized: "renewal.today")
        case 1:    return String(localized: "renewal.tomorrow")
        default:   return String(format: NSLocalizedString("renewal.in_days", comment: ""), subscription.daysUntilRenewal)
        }
    }

    func renewalColor(for subscription: Subscription) -> Color {
        switch subscription.daysUntilRenewal {
        case ..<Self.urgentDayThreshold:                          return .red
        case Self.urgentDayThreshold...Self.warningDayThreshold:  return .orange
        default:                                                   return .secondary
        }
    }

    func maskedCard(lastFour: String) -> String {
        "···· \(lastFour)"
    }
}
