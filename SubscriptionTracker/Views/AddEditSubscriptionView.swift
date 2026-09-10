//
//  AddEditSubscriptionView.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

struct AddEditSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var subscription: Subscription?
    @State private var viewModel = AddEditSubscriptionViewModel()

    init(subscription: Subscription? = nil) {
        self.subscription = subscription
        if let s = subscription {
            let vm = AddEditSubscriptionViewModel()
            vm.populate(from: s)
            self._viewModel = State(initialValue: vm)
        }
    }

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name (e.g. Netflix)", text: $vm.name)
                    TextField("Merchant (e.g. Netflix, Inc.)", text: $vm.merchant)
                    HStack {
                        Text("$").foregroundStyle(.secondary)
                        TextField("0.00", text: $vm.amountText)
                            .keyboardType(.decimalPad)
                    }
                    Picker("Billing Cycle", selection: $vm.billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    DatePicker("Next Renewal", selection: $vm.nextRenewal, displayedComponents: .date)
                }

                Section("Category") {
                    Picker("Category", selection: $vm.category) {
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
                        TextField("1234", text: $vm.cardLastFour)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onChange(of: vm.cardLastFour) { _, new in
                                if new.count > AddEditSubscriptionViewModel.maxCardDigits {
                                    vm.cardLastFour = String(new.prefix(AddEditSubscriptionViewModel.maxCardDigits))
                                }
                            }
                    }
                }

                if subscription != nil {
                    Section {
                        Toggle("Active", isOn: $vm.isActive)
                    }
                }

                if let monthly = viewModel.monthlyPreview {
                    Section("Cost Preview") {
                        LabeledContent("Monthly") {
                            Text(monthly, format: .currency(code: "USD"))
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent("Annual") {
                            Text(monthly * AddEditSubscriptionViewModel.monthsPerYear, format: .currency(code: "USD"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(subscription == nil ? "New Subscription" : "Edit Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(editing: subscription, context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}
