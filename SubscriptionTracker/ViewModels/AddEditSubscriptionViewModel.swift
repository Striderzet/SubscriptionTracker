//
//  AddEditSubscriptionViewModel.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

// MARK: - Protocol (ISP / DIP)

/// The interface AddEditSubscriptionView depends on.
/// Mutable `get set` properties are declared here so the view can create
/// @Bindable bindings against the protocol without knowing the concrete type.
protocol AddEditSubscriptionViewModelProtocol: AnyObject {
    var name: String { get set }
    var merchant: String { get set }
    var amountText: String { get set }
    var billingCycle: BillingCycle { get set }
    var nextRenewal: Date { get set }
    var category: SubscriptionCategory { get set }
    var cardLastFour: String { get set }
    var isActive: Bool { get set }
    var isValid: Bool { get }
    var monthlyPreview: Double? { get }
    var annualPreview: Double? { get }
    func populate(from subscription: Subscription)
    func save(editing subscription: Subscription?, context: ModelContext)
}

// MARK: - Implementation

@Observable
final class AddEditSubscriptionViewModel: AddEditSubscriptionViewModelProtocol {

    // MARK: - Layout Constants
    static let cardDigitsFieldWidth: CGFloat = 60

    // MARK: - Business Constants
    static let maxCardDigits = 4
    static let amountFormat = "%.2f"
    /// Resolved at first use from the device locale so amounts are always
    /// formatted and parsed in the user's currency, not hardcoded to USD.
    static let currencyCode: String = Locale.current.currency?.identifier ?? "USD"

    // MARK: - Amount Formatter
    /// Locale-aware formatter shared across parsing and pre-fill so that both
    /// directions use the same decimal separator (e.g. "," in German locale).
    private static let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = .current
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

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
    /// Tries the locale-aware formatter first (handles "9,99" in comma-decimal locales),
    /// then falls back to Swift's C-locale Double() so "9.99" always works regardless of locale.
    var parsedAmount: Double? {
        Self.amountFormatter.number(from: amountText)?.doubleValue ?? Double(amountText)
    }

    var isValid: Bool { !name.isEmpty && !merchant.isEmpty && parsedAmount != nil }

    /// Delegates to BillingCycle.monthlyEquivalent so the conversion formula
    /// is not duplicated between this ViewModel and the Subscription model.
    var monthlyPreview: Double? {
        guard let amount = parsedAmount else { return nil }
        return billingCycle.monthlyEquivalent(for: amount)
    }

    /// Always derived from monthlyPreview so the two values stay in sync and
    /// the view never performs business math inline.
    var annualPreview: Double? {
        monthlyPreview.map { $0 * BillingCycle.monthsPerYear }
    }

    // MARK: - Methods

    /// Copies an existing Subscription's values into the form state so the
    /// fields are pre-filled when the sheet opens in edit mode.
    func populate(from subscription: Subscription) {
        name = subscription.name
        merchant = subscription.merchant
        amountText = Self.amountFormatter.string(from: NSNumber(value: subscription.amount))
            ?? String(format: Self.amountFormat, subscription.amount)
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
