import SwiftUI
import SwiftData

struct AddEditSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var subscription: Subscription?

    @State private var name = ""
    @State private var merchant = ""
    @State private var amountText = ""
    @State private var billingCycle = BillingCycle.monthly
    @State private var nextRenewal = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var category = SubscriptionCategory.other
    @State private var cardLastFour = ""
    @State private var isActive = true

    private var isEditing: Bool { subscription != nil }
    private var parsedAmount: Double? { Double(amountText) }
    private var isValid: Bool { !name.isEmpty && !merchant.isEmpty && parsedAmount != nil }

    private var monthlyPreview: Double? {
        guard let amount = parsedAmount else { return nil }
        return switch billingCycle {
        case .monthly: amount
        case .annual: amount / 12.0
        case .weekly: amount * 4.33
        }
    }

    init(subscription: Subscription? = nil) {
        self.subscription = subscription
        if let s = subscription {
            _name = State(initialValue: s.name)
            _merchant = State(initialValue: s.merchant)
            _amountText = State(initialValue: String(format: "%.2f", s.amount))
            _billingCycle = State(initialValue: s.billingCycle)
            _nextRenewal = State(initialValue: s.nextRenewal)
            _category = State(initialValue: s.category)
            _cardLastFour = State(initialValue: s.cardLastFour)
            _isActive = State(initialValue: s.isActive)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name (e.g. Netflix)", text: $name)
                    TextField("Merchant (e.g. Netflix, Inc.)", text: $merchant)
                    HStack {
                        Text("$").foregroundStyle(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    DatePicker("Next Renewal", selection: $nextRenewal, displayedComponents: .date)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Card on File") {
                    HStack {
                        Text("Last 4 digits").foregroundStyle(.secondary)
                        Spacer()
                        TextField("1234", text: $cardLastFour)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onChange(of: cardLastFour) { _, new in
                                if new.count > 4 { cardLastFour = String(new.prefix(4)) }
                            }
                    }
                }

                if isEditing {
                    Section {
                        Toggle("Active", isOn: $isActive)
                    }
                }

                if let monthly = monthlyPreview {
                    Section("Cost Preview") {
                        LabeledContent("Monthly") {
                            Text(monthly, format: .currency(code: "USD"))
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent("Annual") {
                            Text(monthly * 12, format: .currency(code: "USD"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "New Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).disabled(!isValid)
                }
            }
        }
    }

    private func save() {
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
            modelContext.insert(Subscription(
                name: name,
                merchant: merchant,
                amount: amount,
                billingCycle: billingCycle,
                nextRenewal: nextRenewal,
                category: category,
                cardLastFour: cardLastFour
            ))
        }
        dismiss()
    }
}
