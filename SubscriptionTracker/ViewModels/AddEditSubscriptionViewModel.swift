import SwiftUI
import SwiftData

@Observable
final class AddEditSubscriptionViewModel {

    // MARK: - Constants
    static let weeksPerMonth: Double = 4.33
    static let monthsPerYear: Double = 12.0
    static let maxCardDigits = 4
    static let amountFormat = "%.2f"

    // MARK: - Form State
    var name = ""
    var merchant = ""
    var amountText = ""
    var billingCycle = BillingCycle.monthly
    var nextRenewal = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    var category = SubscriptionCategory.other
    var cardLastFour = ""
    var isActive = true

    // MARK: - Computed
    var parsedAmount: Double? { Double(amountText) }

    var isValid: Bool { !name.isEmpty && !merchant.isEmpty && parsedAmount != nil }

    var monthlyPreview: Double? {
        guard let amount = parsedAmount else { return nil }
        return switch billingCycle {
        case .monthly: amount
        case .annual:  amount / Self.monthsPerYear
        case .weekly:  amount * Self.weeksPerMonth
        }
    }

    // MARK: - Methods
    func populate(from subscription: Subscription) {
        name = subscription.name
        merchant = subscription.merchant
        amountText = String(format: Self.amountFormat, subscription.amount)
        billingCycle = subscription.billingCycle
        nextRenewal = subscription.nextRenewal
        category = subscription.category
        cardLastFour = subscription.cardLastFour
        isActive = subscription.isActive
    }

    func save(editing subscription: Subscription?, context: ModelContext) {
        guard let amount = parsedAmount else { return }
        if let sub = subscription {
            sub.name = name
            sub.merchant = merchant
            sub.amount = amount
            sub.billingCycle = billingCycle
            sub.nextRenewal = nextRenewal
            sub.category = category
            sub.cardLastFour = cardLastFour
            sub.isActive = isActive
        } else {
            context.insert(Subscription(
                name: name,
                merchant: merchant,
                amount: amount,
                billingCycle: billingCycle,
                nextRenewal: nextRenewal,
                category: category,
                cardLastFour: cardLastFour
            ))
        }
    }
}
