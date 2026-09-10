import SwiftUI
import SwiftData

@main
struct SubscriptionTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                SubscriptionListView()
                    .tabItem { Label("Subscriptions", systemImage: "creditcard.fill") }
                SummaryView()
                    .tabItem { Label("Summary", systemImage: "chart.pie.fill") }
            }
        }
        .modelContainer(for: Subscription.self)
    }
}
