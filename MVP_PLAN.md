# LitheNet MVP Implementation Plan

## Navigation Restructure

Current: Home / Profiles / Rules / Logs / Settings
Target: **Home / Proxies / Subscriptions / Logs / Settings**

| Index | Old | New | Route |
|-------|-----|-----|-------|
| 0 | Home | Home | `/` |
| 1 | Profiles | Proxies | `/proxies` |
| 2 | Rules | Subscriptions | `/subscriptions` |
| 3 | Logs | Logs | `/logs` |
| 4 | Settings | Settings | `/settings` |

---

## Task List

### T1: Navigation + Route Restructure
- Rename `AppRoute.profiles` → `AppRoute.proxies`, path `/proxies`
- Rename `AppRoute.rules` → `AppRoute.subscriptions`, path `/subscriptions`
- Update `app_shell.dart` destinations: labels + icons
- Update router imports
- Delete `features/placeholders/profiles_page.dart` and `rules_page.dart`

### T2: Core Foundation
- Create `lib/core/theme/app_theme.dart` — light + dark ThemeData
- Create `lib/core/theme/app_colors.dart` — semantic color constants
- Create `lib/core/theme/app_spacing.dart` — spacing/radius constants
- Create `lib/core/utils/format_bytes.dart` — extract from home_page
- Create `lib/core/widgets/app_card.dart` — reusable section card
- Create `lib/core/widgets/section_header.dart`
- Create `lib/core/widgets/empty_state.dart`
- Update `lithenet_app.dart` — add darkTheme, use extracted theme

### T3: Data Models
- Create `lib/data/models/subscription.dart`
- Create `lib/data/models/proxy_node.dart`
- Create `lib/data/models/proxy_group.dart`
- Create `lib/data/models/log_entry.dart`
- Create `lib/data/models/app_settings.dart`

### T4: Subscriptions Page
- Create `lib/features/subscriptions/presentation/subscriptions_page.dart`
- Create `lib/features/subscriptions/presentation/widgets/subscription_card.dart`
- Create `lib/features/subscriptions/presentation/widgets/add_subscription_sheet.dart`
- Create `lib/features/subscriptions/presentation/widgets/traffic_quota_bar.dart`
- Create `lib/features/subscriptions/application/subscriptions_controller.dart`

### T5: Proxies Page
- Create `lib/features/proxies/presentation/proxies_page.dart`
- Create `lib/features/proxies/presentation/widgets/mode_selector.dart`
- Create `lib/features/proxies/presentation/widgets/proxy_group_tabs.dart`
- Create `lib/features/proxies/presentation/widgets/proxy_node_tile.dart`
- Create `lib/features/proxies/presentation/widgets/proxy_latency_chip.dart`
- Create `lib/features/proxies/application/proxies_controller.dart`

### T6: Logs Page
- Create `lib/features/logs/presentation/logs_page.dart`
- Create `lib/features/logs/presentation/widgets/log_toolbar.dart`
- Create `lib/features/logs/presentation/widgets/log_line_tile.dart`
- Create `lib/features/logs/application/logs_controller.dart`

### T7: Settings Page
- Create `lib/features/settings/presentation/settings_page.dart` (grouped list)
- Create `lib/features/settings/presentation/general_settings_page.dart`
- Create `lib/features/settings/presentation/network_settings_page.dart`
- Create `lib/features/settings/presentation/appearance_settings_page.dart`
- Create `lib/features/settings/presentation/about_page.dart`
- Create `lib/features/settings/application/settings_controller.dart`

### T8: Home Page Simplify
- Refactor home_page.dart to match blueprint: CurrentProfileCard, ConnectionButton, TrafficStatsCard, QuickActionsGrid
- Remove ConfigEditorCard from home (move to settings/advanced)
- Remove CurrentConfigCard endpoint editing from home

---

## Execution Order

```
T1 → T2 → T3 → T4 → T5 → T6 → T7 → T8
```

Each task must compile and run independently.
