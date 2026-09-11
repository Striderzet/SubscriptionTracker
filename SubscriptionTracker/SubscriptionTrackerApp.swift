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
    let container: ModelContainer

    init() {
        // UI tests pass --uitesting to isolate each run in an in-memory store so
        // persistent data from a previous run never bleeds into the next test.
        let inMemory = CommandLine.arguments.contains("--uitesting")
        do {
            container = try ModelContainer(
                for: Subscription.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
            )
        } catch {
            // A failed init means the on-disk store is corrupted or the OS denied
            // access. fatalError is intentional here — there is no meaningful UI we
            // can show without a working store, and the crash log will surface the
            // underlying SQLite/OS error for diagnosis.
            fatalError("SwiftData failed to initialize — store may be corrupted: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                SubscriptionListView()
                    .tabItem { Label(SubscriptionListViewModel.navigationTitle, systemImage: SubscriptionListViewModel.tabIcon) }
                SummaryView()
                    .tabItem { Label(SummaryViewModel.navigationTitle, systemImage: SummaryViewModel.tabIcon) }
            }
        }
        .modelContainer(container)
    }
}
