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
                    .tabItem { Label(SubscriptionListViewModel.navigationTitle, systemImage: SubscriptionListViewModel.tabIcon) }
                SummaryView()
                    .tabItem { Label(SummaryViewModel.navigationTitle, systemImage: SummaryViewModel.tabIcon) }
            }
        }
        .modelContainer(for: Subscription.self)
    }
}
