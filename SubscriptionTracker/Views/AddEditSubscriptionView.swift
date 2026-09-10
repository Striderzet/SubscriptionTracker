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
                Section(AddEditSubscriptionViewModel.sectionDetails) {
                    TextField(AddEditSubscriptionViewModel.fieldNamePlaceholder, text: $vm.name)
                    TextField(AddEditSubscriptionViewModel.fieldMerchantPlaceholder, text: $vm.merchant)
                    HStack {
                        Text(AddEditSubscriptionViewModel.fieldCurrencyPrefix).foregroundStyle(.secondary)
                        TextField(AddEditSubscriptionViewModel.fieldAmountPlaceholder, text: $vm.amountText)
                            .keyboardType(.decimalPad)
                    }
                    Picker(AddEditSubscriptionViewModel.fieldBillingCycleLabel, selection: $vm.billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { Text($0.localizedName).tag($0) }
                    }
                    DatePicker(AddEditSubscriptionViewModel.fieldNextRenewalLabel, selection: $vm.nextRenewal, displayedComponents: .date)
                }

                Section(AddEditSubscriptionViewModel.sectionCategory) {
                    Picker(AddEditSubscriptionViewModel.fieldCategoryLabel, selection: $vm.category) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                            Label(cat.localizedName, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section(AddEditSubscriptionViewModel.sectionCard) {
                    HStack {
                        Text(AddEditSubscriptionViewModel.fieldCardLabel).foregroundStyle(.secondary)
                        Spacer()
                        TextField(AddEditSubscriptionViewModel.fieldCardPlaceholder, text: $vm.cardLastFour)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: AddEditSubscriptionViewModel.cardDigitsFieldWidth)
                            .onChange(of: vm.cardLastFour) { _, new in
                                if new.count > AddEditSubscriptionViewModel.maxCardDigits {
                                    vm.cardLastFour = String(new.prefix(AddEditSubscriptionViewModel.maxCardDigits))
                                }
                            }
                    }
                }

                if subscription != nil {
                    Section {
                        Toggle(AddEditSubscriptionViewModel.toggleActive, isOn: $vm.isActive)
                    }
                }

                if let monthly = viewModel.monthlyPreview {
                    Section(AddEditSubscriptionViewModel.sectionPreview) {
                        LabeledContent(AddEditSubscriptionViewModel.previewLabelMonthly) {
                            Text(monthly, format: .currency(code: "USD"))
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent(AddEditSubscriptionViewModel.previewLabelAnnual) {
                            Text(monthly * AddEditSubscriptionViewModel.monthsPerYear, format: .currency(code: "USD"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(subscription == nil ? AddEditSubscriptionViewModel.titleNew : AddEditSubscriptionViewModel.titleEdit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AddEditSubscriptionViewModel.buttonCancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AddEditSubscriptionViewModel.buttonSave) {
                        viewModel.save(editing: subscription, context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}
