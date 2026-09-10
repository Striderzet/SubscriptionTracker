import SwiftUI
import SwiftData

@Observable
final class SummaryViewModel {

    // MARK: - Chart Constants
    static let chartHeight: CGFloat = 200
    static let chartInnerRadiusRatio: CGFloat = 0.6
    static let chartAngularInset: CGFloat = 1.5
    static let chartCornerRadius: CGFloat = 4

    // MARK: - Renewal Constants
    static let upcomingWindowDays = 30
    static let urgentRenewalThreshold = 3

    // MARK: - Strings
    static let emptyStateTitle = "No Data Yet"
    static let emptyStateIcon = "chart.pie.fill"
    static let emptyStateDescription = "Add subscriptions to see your spending summary."
    static let sectionCategory = "Spending by Category"
    static let sectionUpcoming = "Renewing in 30 Days"

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
        subscription.daysUntilRenewal == 0 ? "Today" : "in \(subscription.daysUntilRenewal)d"
    }

    func isUrgent(_ subscription: Subscription) -> Bool {
        subscription.daysUntilRenewal <= Self.urgentRenewalThreshold
    }
}
