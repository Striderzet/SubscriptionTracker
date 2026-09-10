//
//  SubscriptionListView.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.nextRenewal) private var subscriptions: [Subscription]
    @State private var viewModel = SubscriptionListViewModel()
    @State private var showingAddSheet = false
    @State private var editingSubscription: Subscription?

    var body: some View {
        NavigationStack {
            List {
                if !subscriptions.isEmpty {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: SubscriptionListViewModel.headerSpacing) {
                                Text(SubscriptionListViewModel.labelMonthlyTotal)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(viewModel.monthlyTotal(in: subscriptions), format: .currency(code: SubscriptionListViewModel.currencyCode))
                                    .font(.title2.bold())
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: SubscriptionListViewModel.headerSpacing) {
                                Text(SubscriptionListViewModel.labelAnnual)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(viewModel.annualTotal(in: subscriptions), format: .currency(code: SubscriptionListViewModel.currencyCode))
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, SubscriptionListViewModel.headerVerticalPadding)
                    }
                }

                let active = viewModel.active(in: subscriptions)
                let inactive = viewModel.inactive(in: subscriptions)

                if !active.isEmpty {
                    Section(SubscriptionListViewModel.sectionActive) {
                        ForEach(active) { sub in
                            SubscriptionRow(subscription: sub, viewModel: viewModel)
                                .contentShape(Rectangle())
                                .onTapGesture { editingSubscription = sub }
                        }
                        .onDelete { offsets in viewModel.delete(from: active, at: offsets, context: modelContext) }
                    }
                }

                if !inactive.isEmpty {
                    Section(SubscriptionListViewModel.sectionInactive) {
                        ForEach(inactive) { sub in
                            SubscriptionRow(subscription: sub, viewModel: viewModel)
                                .contentShape(Rectangle())
                                .onTapGesture { editingSubscription = sub }
                        }
                        .onDelete { offsets in viewModel.delete(from: inactive, at: offsets, context: modelContext) }
                    }
                }
            }
            .navigationTitle(SubscriptionListViewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddSheet = true } label: { Image(systemName: SubscriptionListViewModel.iconAdd) }
                }
            }
            .overlay {
                if subscriptions.isEmpty {
                    ContentUnavailableView(
                        SubscriptionListViewModel.emptyStateTitle,
                        systemImage: SubscriptionListViewModel.emptyStateIcon,
                        description: Text(SubscriptionListViewModel.emptyStateDescription)
                    )
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditSubscriptionView()
            }
            .sheet(item: $editingSubscription) { sub in
                AddEditSubscriptionView(subscription: sub)
            }
        }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    let viewModel: SubscriptionListViewModel

    var body: some View {
        HStack(spacing: SubscriptionListViewModel.rowSpacing) {
            CategoryBadge(category: subscription.category)

            VStack(alignment: .leading, spacing: SubscriptionListViewModel.rowTextSpacing) {
                Text(subscription.name).font(.headline)
                HStack(spacing: SubscriptionListViewModel.subtitleSpacing) {
                    Text(subscription.billingCycle.localizedName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !subscription.cardLastFour.isEmpty {
                        Text(SubscriptionListViewModel.separatorDot).foregroundStyle(.tertiary)
                        Text(viewModel.maskedCard(lastFour: subscription.cardLastFour))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: SubscriptionListViewModel.rowTextSpacing) {
                Text(subscription.amount, format: .currency(code: SubscriptionListViewModel.currencyCode)).font(.headline)
                Text(viewModel.renewalText(for: subscription))
                    .font(.caption)
                    .foregroundStyle(viewModel.renewalColor(for: subscription))
            }
        }
        .padding(.vertical, SubscriptionListViewModel.rowVerticalPadding)
        .opacity(subscription.isActive ? SubscriptionListViewModel.activeOpacity : SubscriptionListViewModel.inactiveOpacity)
    }
}

struct CategoryBadge: View {
    let category: SubscriptionCategory

    var body: some View {
        Image(systemName: category.icon)
            .font(.system(size: SubscriptionListViewModel.badgeIconSize, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: SubscriptionListViewModel.badgeSize, height: SubscriptionListViewModel.badgeSize)
            .background(category.color)
            .clipShape(RoundedRectangle(cornerRadius: SubscriptionListViewModel.badgeCornerRadius))
    }
}
