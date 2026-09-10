import SwiftUI
import SwiftData
import Charts

struct SummaryView: View {
    @Query private var subscriptions: [Subscription]

    private var active: [Subscription] { subscriptions.filter(\.isActive) }

    private var monthlyTotal: Double {
        active.reduce(0) { $0 + $1.monthlyEquivalent }
    }

    private var categoryData: [(category: SubscriptionCategory, total: Double)] {
        Dictionary(grouping: active, by: \.category)
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.monthlyEquivalent }) }
            .sorted { $0.total > $1.total }
    }

    private var upcomingRenewals: [Subscription] {
        active
            .filter { $0.daysUntilRenewal >= 0 && $0.daysUntilRenewal <= 30 }
            .sorted { $0.daysUntilRenewal < $1.daysUntilRenewal }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 0) {
                        StatTile(label: "Monthly", amount: monthlyTotal)
                        Divider().padding(.vertical, 8)
                        StatTile(label: "Annual", amount: monthlyTotal * 12)
                    }
                }

                if !categoryData.isEmpty {
                    Section("Spending by Category") {
                        Chart(categoryData, id: \.category) { item in
                            SectorMark(
                                angle: .value("Amount", item.total),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .cornerRadius(4)
                            .foregroundStyle(by: .value("Category", item.category.rawValue))
                        }
                        .frame(height: 200)
                        .padding(.vertical, 8)

                        ForEach(categoryData, id: \.category) { item in
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

                if !upcomingRenewals.isEmpty {
                    Section("Renewing in 30 Days") {
                        ForEach(upcomingRenewals) { sub in
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
                                    Text(sub.daysUntilRenewal == 0 ? "Today" : "in \(sub.daysUntilRenewal)d")
                                        .font(.caption)
                                        .foregroundStyle(sub.daysUntilRenewal <= 3 ? .red : .secondary)
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
                        "No Data Yet",
                        systemImage: "chart.pie.fill",
                        description: Text("Add subscriptions to see your spending summary.")
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
