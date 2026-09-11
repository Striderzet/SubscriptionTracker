# SubscriptionTracker

A production-quality iOS app for tracking and managing recurring subscriptions. Built to demonstrate clean Swift architecture, comprehensive testing, and real-world engineering practices.

---

## Overview

SubscriptionTracker gives users a single place to track every recurring subscription — what they're paying, when it renews, and what it costs them monthly and annually in aggregate. All data is stored locally on-device using SwiftData with zero network calls and full privacy.

---

## Features

- **Add, edit, and archive subscriptions** with name, merchant, amount, billing cycle, category, and card-on-file
- **Three billing cycles** — weekly, monthly, and annual — with automatic monthly equivalent calculations for consistent cost comparisons
- **Active / inactive states** with visual opacity distinction and separate list sections
- **Spending summary** with a donut chart (Swift Charts) breaking down monthly spend by category
- **Renewal dashboard** showing subscriptions due within 30 days, with color-coded urgency (overdue / today / tomorrow / in N days)
- **Masked card display** (`···· 1234`) for at-a-glance card identification
- **Seven categories** — Streaming, Software, Fitness, News, Gaming, Education, Other — each with a distinct SF Symbol and color
- **Full localization** with semantic key/value pairs ready for any language
- **Locale-aware number formatting** — decimal input and amount display adapt to the user's locale (supports comma-decimal markets: Germany, France, Brazil, etc.)
- **Currency resolution** from `Locale.current` — no hardcoded USD assumption

---

## Screenshots

> Add screenshots or a demo GIF here before submission.

| Subscriptions List | Summary | Add Subscription |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

---

## Architecture

### Pattern: MVVM + Service Layer

The codebase uses MVVM with a dedicated service layer that creates four clearly bounded responsibilities:

| Layer | File(s) | Responsibility |
|---|---|---|
| **View** | `Views/` | Renders state. Zero business logic, zero string literals, zero magic numbers |
| **ViewModel** | `ViewModels/` | Owns all constants, orchestrates formatting calls, manages sheet state |
| **Service** | `SubscriptionService.swift` | All shared business logic: filtering, aggregation, formatting, deletion |
| **Model** | `Subscription.swift` | SwiftData persistence schema and domain computed properties |

### SOLID Principles

Each principle is applied deliberately, not mechanically:

**Single Responsibility (SRP)**

`SubscriptionService` is the single owner of all shared business logic. Before the service layer existed, `SubscriptionListViewModel` and `SummaryViewModel` each contained identical implementations of `active(in:)`, `monthlyTotal(in:)`, and friends. Now there is one implementation, in one file, testable in isolation.

**Open / Closed (OCP)**

`BillingCycle.monthlyEquivalent(for:)` is the single source of truth for billing-cycle math. Adding a new billing cycle — say, `.quarterly` — requires touching exactly one switch statement. No ViewModels, no views, no tests need to change.

```swift
func monthlyEquivalent(for amount: Double) -> Double {
    switch self {
    case .weekly:  amount * BillingCycle.weeksPerMonth   // 52 ÷ 12
    case .monthly: amount
    case .annual:  amount / BillingCycle.monthsPerYear
    }
}
```

**Liskov Substitution (LSP)**

`MockSubscriptionService` substitutes perfectly for `SubscriptionService` in tests. All 105 unit tests run without touching SwiftData, the file system, or the main actor — because the mock conforms to `SubscriptionServicing` identically.

**Interface Segregation (ISP)**

Each ViewModel exposes its own scoped protocol (`SubscriptionListViewModelProtocol`, `SummaryViewModelProtocol`, `AddEditSubscriptionViewModelProtocol`). Views depend on the protocol, not the concrete class. A UI test harness or SwiftUI preview can substitute a lightweight conformer without inheriting the full ViewModel.

**Dependency Inversion (DIP)**

ViewModels accept `any SubscriptionServicing` through their initializer. Production code uses the default `SubscriptionService()`; tests inject `MockSubscriptionService`. Neither side knows about the other.

```swift
@Observable
final class SubscriptionListViewModel: SubscriptionListViewModelProtocol {
    private let service: any SubscriptionServicing

    init(service: any SubscriptionServicing = SubscriptionService()) {
        self.service = service
    }
}
```

### Zero Literal Values in Views

Every string, SF Symbol name, color, opacity, spacing constant, and threshold is defined as a named `static let` on the relevant ViewModel. Views contain no string literals and no magic numbers. This means:

- Changing an SF Symbol is a single-site edit in the ViewModel constant
- Changing the urgency threshold from 3 days to 5 days is one line
- Localized strings are never scattered across view files

### Localization Strategy

All user-facing strings use semantic dot-notation keys (`"list.navigation.title"`, `"renewal.in_days"`, `"form.button.save"`) rather than English text as the key. This decouples the SwiftData persistence format (enum raw values like `"Streaming"`) from the display strings, meaning:

- Changing the English label for a category never requires a data migration
- Adding a new language requires only a new `.strings` file — no source changes
- `NSLocalizedString` and `String(localized:)` are unified to `String(localized:)` throughout

Amounts use a `NumberFormatter` configured with `Locale.current` so that both parsing (user input) and display (pre-fill on edit) use the same decimal separator — preventing the silent data-loss bug where a German user types `9,99`, it fails to parse, and the Save button is permanently disabled.

---

## Tech Stack

| Technology | Version | Usage |
|---|---|---|
| Swift | 5.9 | Language |
| SwiftUI | iOS 17+ | Declarative UI, `@Observable`, `@Query`, `@Model` |
| SwiftData | iOS 17+ | On-device persistence, in-memory test isolation |
| Swift Charts | iOS 16+ | Category spending donut chart |
| XCTest | Xcode 16 | Unit testing and UI automation |

No third-party dependencies. No package manager.

---

## Testing

### Unit Tests — 105 tests, targeting 100% coverage

Tests are organized by layer. ViewModels are tested through `MockSubscriptionService` — no disk I/O, no main actor, fully deterministic. SwiftData operations use an in-memory `ModelContainer` scoped to each test method.

| Test File | What It Covers |
|---|---|
| `BillingCycleTests` | Constants (`weeksPerMonth`, `monthsPerYear`), `monthlyEquivalent` for all three cycles and zero amount, `localizedName` non-empty and distinct, raw values (persistence contract) |
| `SubscriptionCategoryTests` | `allCases` count, icon SF Symbol names, color branch execution, `localizedName`, raw values |
| `SubscriptionModelTests` | `monthlyEquivalent` delegation to `BillingCycle`, `daysUntilRenewal` for today / tomorrow / overdue / future, init defaults |
| `SubscriptionServiceTests` | All 10 service methods: active/inactive filtering, monthly/annual totals, category grouping and sort order, upcoming renewals (boundary cases), renewal text (4 branches), renewal color (3 branches), masked card, SwiftData delete |
| `SubscriptionListViewModelTests` | All 9 layout constants, 2 threshold constants, 2 opacity constants, 4 icon/format constants, delegation to mock for all 8 protocol methods, threshold forwarding to service |
| `SummaryViewModelTests` | All 5 chart constants, 5 layout constants, 2 renewal constants, chart accessibility label strings, delegation for all 6 protocol methods, `isUrgent` true/false/at-threshold |
| `AddEditSubscriptionViewModelTests` | Constants, default form state (7 fields), `parsedAmount` (valid/invalid/empty), `isValid` (4 branches), `monthlyPreview` (all 3 cycles + nil), `annualPreview` (valid + nil), `populate(from:)` all fields, `save` (new/edit/invalid guard) |

**Testing philosophy:**

- `Double?` computed properties always go through `XCTUnwrap` before `accuracy:` assertions — a missing result is an explicit failure, never a silent pass
- Color equality is asserted directly (`XCTAssertEqual(color, .red)`) — `Color` is `Hashable` and therefore `Equatable`
- `@MainActor` is applied at the test class level for `AddEditSubscriptionViewModelTests` and per-method for SwiftData operations elsewhere, matching SwiftData's concurrency requirements

### UI Tests — 17 tests, full screen regression coverage

UI tests launch the app with `--uitesting`, which switches the `ModelContainer` to an in-memory store. Each test starts with a clean, empty, isolated dataset. `tearDown` terminates the app after each test for clean simulator state.

| Group | Tests |
|---|---|
| **Launch & Navigation** | Launches on Subscriptions tab; list empty state visible; Summary tab navigable; Summary empty state visible |
| **Add Flow** | Add button opens form; Cancel dismisses; Save disabled with empty form; Save enables with required fields; cost preview section appears with valid amount; form has Details / Category / Card sections; Billing Cycle field present; subscription appears in list after save; form dismisses on save |
| **Edit Flow** | Tapping a row opens Edit Subscription form; name field pre-populated; Active toggle visible |
| **Delete** | Swipe-left on subscription row reveals Delete; tapping Delete returns list to empty state |
| **Summary With Data** | Monthly and Annual stat tiles appear; Spending by Category section appears |

---

## Project Structure

```
SubscriptionTracker/
├── SubscriptionTrackerApp.swift       # App entry point, ModelContainer init
├── Models/
│   └── Subscription.swift             # @Model, BillingCycle, SubscriptionCategory
├── Services/
│   └── SubscriptionService.swift      # SubscriptionServicing protocol + implementation
├── ViewModels/
│   ├── SubscriptionListViewModel.swift
│   ├── SummaryViewModel.swift
│   └── AddEditSubscriptionViewModel.swift
├── Views/
│   ├── SubscriptionListView.swift
│   ├── SummaryView.swift
│   └── AddEditSubscriptionView.swift
├── en.lproj/
│   └── Localizable.strings            # Semantic key/value pairs
└── PrivacyInfo.xcprivacy              # App Store privacy manifest

SubscriptionTrackerTests/              # 105 unit tests
└── MockSubscriptionService.swift      # Configurable test double + shared helpers

SubscriptionTrackerUITests/            # 17 UI regression tests
└── SubscriptionTrackerUITests.swift
```

---

## Privacy

`PrivacyInfo.xcprivacy` declares:

- **No user tracking** (`NSPrivacyTracking: false`)
- **No data collected or transmitted** — all subscription data is stored exclusively on-device
- **File-timestamp API access** declared for SwiftData's SQLite store (reason C617.1)

The app makes zero network requests.

---

## Requirements

| Requirement | Minimum |
|---|---|
| Xcode | 16.0+ |
| iOS Deployment Target | 17.0 |
| Swift | 5.9 |
| Device | iPhone (portrait and landscape) |

---

## Setup

```bash
git clone https://github.com/Striderzet/SubscriptionTracker.git
cd SubscriptionTracker
open SubscriptionTracker.xcodeproj
```

Build and run on any iOS 17+ Simulator with **Cmd+R**. No dependencies to install, no API keys to configure.

To run the unit test suite: **Cmd+U**

---

## Known Limitations & Future Work

These are acknowledged trade-offs, not oversights:

| Area | Current State | Production Path |
|---|---|---|
| **App icon** | Placeholder asset | Replace with 1024×1024 production icon |
| **Schema versioning** | No `VersionedSchema` yet | Add `SchemaV1` + `MigrationPlan` before the first update that modifies `Subscription`'s stored properties — nothing to migrate before v1 ships |
| **Financial precision** | `Double` arithmetic | Fintech production code would use `Decimal` to avoid floating-point accumulation (e.g. `weeksPerMonth = 4.33` vs `52/12`) |
| **SwiftUI.Color in service** | `renewalColor` returns `Color`, coupling the service to SwiftUI | Return a `RenewalUrgency` enum and resolve color in the view layer |
| **Pagination** | `@Query` loads all subscriptions | Use predicate-filtered `FetchDescriptor` with a limit for users with very large datasets |
| **Multi-currency** | Single currency per device locale | Per-subscription currency with an exchange-rate API for aggregate conversions |

---

## Author

Tony Buckner — [tony.buckner26@gmail.com](mailto:tony.buckner26@gmail.com)
