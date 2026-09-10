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

    // MARK: - Renewal Thresholds
    static let urgentDayThreshold = 1
    static let warningDayThreshold = 3

    // MARK: - Strings
    static let emptyStateTitle = "No Subscriptions"
    static let emptyStateIcon = "creditcard.fill"
    static let emptyStateDescription = "Tap + to track your first subscription."
    static let sectionActive = "Active"
    static let sectionInactive = "Inactive"

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

    func delete(from list: [Subscription], at offsets: IndexSet, context: ModelContext) {
        offsets.forEach { context.delete(list[$0]) }
    }

    // MARK: - Formatting
    func renewalText(for subscription: Subscription) -> String {
        switch subscription.daysUntilRenewal {
        case ..<0: return "Overdue"
        case 0:    return "Today"
        case 1:    return "Tomorrow"
        default:   return "in \(subscription.daysUntilRenewal)d"
        }
    }

    func renewalColor(for subscription: Subscription) -> Color {
        switch subscription.daysUntilRenewal {
        case ..<Self.urgentDayThreshold:                              return .red
        case Self.urgentDayThreshold...Self.warningDayThreshold:     return .orange
        default:                                                      return .secondary
        }
    }
}
