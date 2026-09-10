//
//  AddEditSubscriptionViewModel.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

@Observable
final class AddEditSubscriptionViewModel {

    // MARK: - Layout Constants
    static let cardDigitsFieldWidth: CGFloat = 60

    // MARK: - Business Constants
    static let weeksPerMonth: Double = 4.33
    static let monthsPerYear: Double = 12.0
    static let maxCardDigits = 4
    static let amountFormat = "%.2f"
    static let currencyCode = "USD"

    // MARK: - Navigation Strings
    static let titleNew: LocalizedStringKey = "form.title.new"
    static let titleEdit: LocalizedStringKey = "form.title.edit"

    // MARK: - Section Strings
    static let sectionDetails: LocalizedStringKey = "form.section.details"
    static let sectionCategory: LocalizedStringKey = "form.section.category"
    static let sectionCard: LocalizedStringKey = "form.section.card"
    static let sectionPreview: LocalizedStringKey = "form.section.preview"

    // MARK: - Field Strings
    static let fieldNamePlaceholder: LocalizedStringKey = "form.field.name"
    static let fieldMerchantPlaceholder: LocalizedStringKey = "form.field.merchant"
    static let fieldAmountPlaceholder: LocalizedStringKey = "form.field.amount"
    static let fieldBillingCycleLabel: LocalizedStringKey = "form.field.billing_cycle"
    static let fieldNextRenewalLabel: LocalizedStringKey = "form.field.next_renewal"
    static let fieldCategoryLabel: LocalizedStringKey = "form.field.category"
    static let fieldCardLabel: LocalizedStringKey = "form.field.card.label"
    static let fieldCardPlaceholder: LocalizedStringKey = "form.field.card.placeholder"
    static let fieldCurrencyPrefix: LocalizedStringKey = "form.field.currency.prefix"
    static let toggleActive: LocalizedStringKey = "form.toggle.active"
    static let previewLabelMonthly: LocalizedStringKey = "form.preview.monthly"
    static let previewLabelAnnual: LocalizedStringKey = "form.preview.annual"
    static let buttonCancel: LocalizedStringKey = "form.button.cancel"
    static let buttonSave: LocalizedStringKey = "form.button.save"

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
