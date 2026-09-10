//
//  SummaryView.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import SwiftUI
import SwiftData
import Charts

struct SummaryView: View {
    @Query private var subscriptions: [Subscription]
    @State private var viewModel = SummaryViewModel()

    var body: some View {
        NavigationStack {
            List {
                let monthly = viewModel.monthlyTotal(in: subscriptions)
                Section {
                    HStack(spacing: SummaryViewModel.tileDividerSpacing) {
                        StatTile(label: SummaryViewModel.labelMonthly, amount: monthly)
                        Divider().padding(.vertical, SummaryViewModel.tileVerticalPadding)
                        StatTile(label: SummaryViewModel.labelAnnual, amount: monthly * SummaryViewModel.monthsPerYear)
                    }
                }

                let categories = viewModel.categoryData(in: subscriptions)
                if !categories.isEmpty {
                    Section(SummaryViewModel.sectionCategory) {
                        Chart(categories, id: \.category) { item in
                            SectorMark(
                                angle: .value(SummaryViewModel.chartLabelAmount, item.total),
                                innerRadius: .ratio(SummaryViewModel.chartInnerRadiusRatio),
                                angularInset: SummaryViewModel.chartAngularInset
                            )
                            .cornerRadius(SummaryViewModel.chartCornerRadius)
                            .foregroundStyle(by: .value(SummaryViewModel.chartLabelCategory, item.category.localizedName))
                        }
                        .frame(height: SummaryViewModel.chartHeight)
                        .padding(.vertical, SummaryViewModel.chartVerticalPadding)

                        ForEach(categories, id: \.category) { item in
                            HStack {
                                Image(systemName: item.category.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: SummaryViewModel.categoryIconWidth)
                                Text(item.category.localizedName)
                                Spacer()
                                Text(item.total, format: .currency(code: SummaryViewModel.currencyCode))
                                    .foregroundStyle(.secondary)
                                Text(SummaryViewModel.labelPerMonth)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }

                let upcoming = viewModel.upcomingRenewals(in: subscriptions)
                if !upcoming.isEmpty {
                    Section(SummaryViewModel.sectionUpcoming) {
                        ForEach(upcoming) { sub in
                            HStack(spacing: SummaryViewModel.rowSpacing) {
                                CategoryBadge(category: sub.category)
                                VStack(alignment: .leading, spacing: SummaryViewModel.rowTextSpacing) {
                                    Text(sub.name).font(.headline)
                                    Text(sub.nextRenewal, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: SummaryViewModel.rowTextSpacing) {
                                    Text(sub.amount, format: .currency(code: SummaryViewModel.currencyCode))
                                    Text(viewModel.renewalLabel(for: sub))
                                        .font(.caption)
                                        .foregroundStyle(viewModel.isUrgent(sub) ? .red : .secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(SummaryViewModel.navigationTitle)
            .overlay {
                if subscriptions.isEmpty {
                    ContentUnavailableView(
                        SummaryViewModel.emptyStateTitle,
                        systemImage: SummaryViewModel.emptyStateIcon,
                        description: Text(SummaryViewModel.emptyStateDescription)
                    )
                }
            }
        }
    }
}

struct StatTile: View {
    let label: LocalizedStringKey
    let amount: Double

    var body: some View {
        VStack(spacing: SummaryViewModel.rowTextSpacing) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount, format: .currency(code: SummaryViewModel.currencyCode))
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SummaryViewModel.tileVerticalPadding)
    }
}
