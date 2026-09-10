import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.nextRenewal) private var subscriptions: [Subscription]
    @State private var showingAddSheet = false
    @State private var editingSubscription: Subscription?

    private var active: [Subscription] { subscriptions.filter(\.isActive) }
    private var inactive: [Subscription] { subscriptions.filter { !$0.isActive } }
    private var monthlyTotal: Double { active.reduce(0) { $0 + $1.monthlyEquivalent } }

    var body: some View {
        NavigationStack {
            List {
                if !subscriptions.isEmpty {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Monthly Total")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(monthlyTotal, format: .currency(code: "USD"))
                                    .font(.title2.bold())
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Annual")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(monthlyTotal * 12, format: .currency(code: "USD"))
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                if !active.isEmpty {
                    Section("Active") {
                        ForEach(active) { sub in
                            SubscriptionRow(subscription: sub)
                                .contentShape(Rectangle())
                                .onTapGesture { editingSubscription = sub }
                        }
                        .onDelete { offsets in delete(from: active, at: offsets) }
                    }
                }

                if !inactive.isEmpty {
                    Section("Inactive") {
                        ForEach(inactive) { sub in
                            SubscriptionRow(subscription: sub)
                                .contentShape(Rectangle())
                                .onTapGesture { editingSubscription = sub }
                        }
                        .onDelete { offsets in delete(from: inactive, at: offsets) }
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddSheet = true } label: { Image(systemName: "plus") }
                }
            }
            .overlay {
                if subscriptions.isEmpty {
                    ContentUnavailableView(
                        "No Subscriptions",
                        systemImage: "creditcard.fill",
                        description: Text("Tap + to track your first subscription.")
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

    private func delete(from list: [Subscription], at offsets: IndexSet) {
        offsets.forEach { modelContext.delete(list[$0]) }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            CategoryBadge(category: subscription.category)

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name).font(.headline)
                HStack(spacing: 4) {
                    Text(subscription.billingCycle.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !subscription.cardLastFour.isEmpty {
                        Text("·").foregroundStyle(.tertiary)
                        Text("···· \(subscription.cardLastFour)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(subscription.amount, format: .currency(code: "USD")).font(.headline)
                Text(renewalText(for: subscription))
                    .font(.caption)
                    .foregroundStyle(renewalColor(for: subscription))
            }
        }
        .padding(.vertical, 2)
        .opacity(subscription.isActive ? 1.0 : 0.5)
    }

    private func renewalText(for sub: Subscription) -> String {
        switch sub.daysUntilRenewal {
        case ..<0: return "Overdue"
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "in \(sub.daysUntilRenewal)d"
        }
    }

    private func renewalColor(for sub: Subscription) -> Color {
        switch sub.daysUntilRenewal {
        case ..<1: return .red
        case 1...3: return .orange
        default: return .secondary
        }
    }
}

struct CategoryBadge: View {
    let category: SubscriptionCategory

    var body: some View {
        Image(systemName: category.icon)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(color(for: category))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func color(for category: SubscriptionCategory) -> Color {
        switch category {
        case .streaming: .purple
        case .software: .blue
        case .fitness: .green
        case .news: .orange
        case .gaming: .red
        case .other: .gray
        }
    }
}
