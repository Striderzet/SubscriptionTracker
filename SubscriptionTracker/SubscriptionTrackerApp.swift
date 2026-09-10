//
//  SubscriptionTrackerApp.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

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
