//
//  SubscriptionListViewModel.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

// MARK: - Protocol (ISP / DIP)

protocol SubscriptionListViewModelProtocol: AnyObject {
    func active(in subscriptions: [Subscription]) -> [Subscription]
    func inactive(in subscriptions: [Subscription]) -> [Subscription]
    func monthlyTotal(in subscriptions: [Subscription]) -> Double
    func annualTotal(in subscriptions: [Subscription]) -> Double
    func delete(from list: [Subscription], at offsets: IndexSet, context: ModelContext)
    func renewalText(for subscription: Subscription) -> String
    func renewalColor(for subscription: Subscription) -> Color
    func maskedCard(lastFour: String) -> String
}

// MARK: - Implementation

@Observable
final class SubscriptionListViewModel: SubscriptionListViewModelProtocol {

    // MARK: - Dependencies (DIP)
    private let service: any SubscriptionServicing

    init(service: any SubscriptionServicing = SubscriptionService()) {
        self.service = service
    }

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
    static let navigationTitle: LocalizedStringKey = "list.navigation.title"
    static let labelMonthlyTotal: LocalizedStringKey = "list.label.monthly_total"
    static let labelAnnual: LocalizedStringKey = "list.label.annual"
    static let separatorDot: LocalizedStringKey = "list.separator"
    static let emptyStateTitle: LocalizedStringKey = "list.empty.title"
    static let emptyStateDescription: LocalizedStringKey = "list.empty.description"
    static let emptyStateIcon = "creditcard.fill"
    static let sectionActive: LocalizedStringKey = "list.section.active"
    static let sectionInactive: LocalizedStringKey = "list.section.inactive"

    // MARK: - Data (delegated to service — SRP)
    func active(in subscriptions: [Subscription]) -> [Subscription] {
        service.active(in: subscriptions)
    }

    func inactive(in subscriptions: [Subscription]) -> [Subscription] {
        service.inactive(in: subscriptions)
    }

    func monthlyTotal(in subscriptions: [Subscription]) -> Double {
        service.monthlyTotal(in: subscriptions)
    }

    func annualTotal(in subscriptions: [Subscription]) -> Double {
        service.annualTotal(in: subscriptions)
    }

    func delete(from list: [Subscription], at offsets: IndexSet, context: ModelContext) {
        service.delete(from: list, at: offsets, context: context)
    }

    // MARK: - Formatting (delegated to service — SRP)
    func renewalText(for subscription: Subscription) -> String {
        service.renewalText(for: subscription)
    }

    func renewalColor(for subscription: Subscription) -> Color {
        service.renewalColor(
            for: subscription,
            urgentThreshold: Self.urgentDayThreshold,
            warningThreshold: Self.warningDayThreshold
        )
    }

    func maskedCard(lastFour: String) -> String {
        service.maskedCard(lastFour: lastFour)
    }
}
