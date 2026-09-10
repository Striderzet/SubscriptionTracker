//
//  Subscription.swift
//  SubscriptionTracker
//
//  Created by Tony Buckner on 9/10/26.
//

import Foundation
import SwiftData
import SwiftUI

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case annual = "Annual"

    var localizedName: String {
        switch self {
        case .weekly:  NSLocalizedString("billing.weekly", comment: "")
        case .monthly: NSLocalizedString("billing.monthly", comment: "")
        case .annual:  NSLocalizedString("billing.annual", comment: "")
        }
    }
}

enum SubscriptionCategory: String, Codable, CaseIterable {
    case streaming = "Streaming"
    case software = "Software"
    case fitness = "Fitness"
    case news = "News"
    case gaming = "Gaming"
    case other = "Other"

    var icon: String {
        switch self {
        case .streaming: "play.tv.fill"
        case .software: "laptopcomputer"
        case .fitness: "figure.run"
        case .news: "newspaper.fill"
        case .gaming: "gamecontroller.fill"
        case .other: "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .streaming: .purple
        case .software: .blue
        case .fitness: .green
        case .news: .orange
        case .gaming: .red
        case .other: .gray
        }
    }

    var localizedName: String {
        switch self {
        case .streaming: NSLocalizedString("category.streaming", comment: "")
        case .software:  NSLocalizedString("category.software", comment: "")
        case .fitness:   NSLocalizedString("category.fitness", comment: "")
        case .news:      NSLocalizedString("category.news", comment: "")
        case .gaming:    NSLocalizedString("category.gaming", comment: "")
        case .other:     NSLocalizedString("category.other", comment: "")
        }
    }
}

@Model
final class Subscription {
    var name: String
    var merchant: String
    var amount: Double
    var billingCycle: BillingCycle
    var nextRenewal: Date
    var category: SubscriptionCategory
    var cardLastFour: String
    var isActive: Bool
    var createdAt: Date

    init(
        name: String,
        merchant: String,
        amount: Double,
        billingCycle: BillingCycle = .monthly,
        nextRenewal: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
        category: SubscriptionCategory = .other,
        cardLastFour: String = "",
        isActive: Bool = true
    ) {
        self.name = name
        self.merchant = merchant
        self.amount = amount
        self.billingCycle = billingCycle
        self.nextRenewal = nextRenewal
        self.category = category
        self.cardLastFour = cardLastFour
        self.isActive = isActive
        self.createdAt = Date()
    }

    var monthlyEquivalent: Double {
        switch billingCycle {
        case .weekly: amount * 4.33
        case .monthly: amount
        case .annual: amount / 12.0
        }
    }

    var daysUntilRenewal: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let renewal = Calendar.current.startOfDay(for: nextRenewal)
        return Calendar.current.dateComponents([.day], from: today, to: renewal).day ?? 0
    }
}
