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
                    HStack(spacing: 0) {
                        StatTile(label: "Monthly", amount: monthly)
                        Divider().padding(.vertical, 8)
                        StatTile(label: "Annual", amount: monthly * 12)
                    }
                }

                let categories = viewModel.categoryData(in: subscriptions)
                if !categories.isEmpty {
                    Section(SummaryViewModel.sectionCategory) {
                        Chart(categories, id: \.category) { item in
                            SectorMark(
                                angle: .value("Amount", item.total),
                                innerRadius: .ratio(SummaryViewModel.chartInnerRadiusRatio),
                                angularInset: SummaryViewModel.chartAngularInset
                            )
                            .cornerRadius(SummaryViewModel.chartCornerRadius)
                            .foregroundStyle(by: .value("Category", item.category.rawValue))
                        }
                        .frame(height: SummaryViewModel.chartHeight)
                        .padding(.vertical, 8)

                        ForEach(categories, id: \.category) { item in
                            HStack {
                                Image(systemName: item.category.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 22)
                                Text(item.category.rawValue)
                                Spacer()
                                Text(item.total, format: .currency(code: "USD"))
                                    .foregroundStyle(.secondary)
                                Text("/ mo")
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
                            HStack(spacing: 12) {
                                CategoryBadge(category: sub.category)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sub.name).font(.headline)
                                    Text(sub.nextRenewal, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(sub.amount, format: .currency(code: "USD"))
                                    Text(viewModel.renewalLabel(for: sub))
                                        .font(.caption)
                                        .foregroundStyle(viewModel.isUrgent(sub) ? .red : .secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Summary")
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
    let label: String
    let amount: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount, format: .currency(code: "USD"))
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
