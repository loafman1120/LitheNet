# LitheNet UI Architecture

## 目录结构

```
lib/
├── main.dart                              # 入口
├── app/
│   ├── lithenet_app.dart                  # 根 Widget，持有 ProxyRepository + ThemeMode
│   ├── router.dart                        # go_router 路由定义
│   └── shell/
│       └── app_shell.dart                 # 自适应导航壳（BottomNav / NavigationRail）
│
├── core/                                  # 跨功能共享的基础层
│   ├── theme/
│   │   ├── app_theme.dart                 # Material 3 light/dark ThemeData
│   │   ├── app_colors.dart                # 语义颜色常量（success/warning/error/upload/download）
│   │   └── app_spacing.dart               # 间距/圆角/尺寸常量
│   ├── utils/
│   │   └── format_bytes.dart              # formatBytes() / formatSpeed()
│   └── widgets/
│       ├── app_card.dart                  # 带标题的通用卡片
│       ├── section_header.dart            # 分段标题行
│       └── empty_state.dart               # 空状态占位（图标 + 标题 + 操作按钮）
│
├── data/
│   └── models/                            # 不可变数据模型（全部使用 copyWith 模式）
│       ├── subscription.dart              # Subscription
│       ├── proxy_node.dart                # ProxyNode
│       ├── proxy_group.dart               # ProxyGroup（包含 List<ProxyNode>）
│       ├── log_entry.dart                 # LogEntry + LogLevel 枚举
│       └── app_settings.dart              # AppSettings + ThemeModeOption 枚举
│
├── features/                              # 功能模块（feature-first 组织）
│   ├── home/
│   │   └── home_page.dart                 # 首页仪表盘（连接按钮 + 流量 + 快捷操作）
│   │
│   ├── proxies/
│   │   ├── application/
│   │   │   └── proxies_controller.dart    # ProxiesController（ChangeNotifier）
│   │   └── presentation/
│   │       ├── proxies_page.dart          # 代理页主页面
│   │       └── widgets/
│   │           ├── mode_selector.dart     # Rule/Global/Direct 模式切换
│   │           ├── proxy_group_tabs.dart  # 策略组横向 Tab
│   │           ├── proxy_node_tile.dart   # 节点列表项（国旗 + 延迟 + 选中态）
│   │           ├── proxy_latency_chip.dart # 颜色编码延迟标签
│   │           └── proxy_node_detail_sheet.dart # 节点详情 BottomSheet
│   │
│   ├── subscriptions/
│   │   ├── application/
│   │   │   └── subscriptions_controller.dart # SubscriptionsController（ChangeNotifier）
│   │   └── presentation/
│   │       ├── subscriptions_page.dart    # 订阅列表页
│   │       └── widgets/
│   │           ├── subscription_card.dart  # 订阅卡片（流量条 + 到期时间 + 菜单）
│   │           ├── add_subscription_sheet.dart # 添加订阅 BottomSheet
│   │           └── traffic_quota_bar.dart  # 流量配额可视化条
│   │
│   ├── logs/
│   │   ├── application/
│   │   │   └── logs_controller.dart       # LogsController（ChangeNotifier）
│   │   └── presentation/
│   │       ├── logs_page.dart             # 日志页主页面
│   │       └── widgets/
│   │           ├── log_toolbar.dart       # 工具栏（暂停/搜索/等级过滤）
│   │           └── log_line_tile.dart     # 单行日志（时间 + 等级标签 + 来源 + 消息）
│   │
│   └── settings/
│       ├── application/
│       │   └── settings_controller.dart   # SettingsController（ChangeNotifier）
│       └── presentation/
│           ├── settings_page.dart          # 设置分组列表页
│           ├── general_settings_page.dart  # 基础设置子页
│           ├── network_settings_page.dart  # 网络设置子页
│           ├── appearance_settings_page.dart # 外观设置子页
│           └── about_page.dart            # 关于页
│
└── repositories/
    └── proxy_repository.dart              # 核心仓库层（singbox-ffi 桥接）
```

---

## 分层架构

```
┌──────────────────────────────────────────────────────┐
│                     UI Layer                          │
│  Pages → Widgets → (AnimatedBuilder rebuilds)        │
│                                                      │
│  HomePage / ProxiesPage / SubscriptionsPage /        │
│  LogsPage / SettingsPage                             │
├──────────────────────────────────────────────────────┤
│               Controller Layer                       │
│  ProxiesController                                   │
│  SubscriptionsController                             │
│  LogsController                                      │
│  SettingsController                                  │
│  (all extend ChangeNotifier)                         │
├──────────────────────────────────────────────────────┤
│                Data Model Layer                      │
│  Subscription / ProxyNode / ProxyGroup /             │
│  LogEntry / AppSettings / TrafficSnapshot            │
│  (all @immutable with copyWith)                      │
├──────────────────────────────────────────────────────┤
│               Repository Layer                       │
│  ProxyRepository (abstract)                          │
│    └── SingboxProxyRepository (concrete)             │
│       wraps singbox_ffi native plugin                │
├──────────────────────────────────────────────────────┤
│               Native Layer                           │
│  singbox_ffi (C library via FFI)                     │
└──────────────────────────────────────────────────────┘
```

---

## 状态管理

### 全局状态：ProxyRepository（InheritedNotifier）

```
LitheNetApp
  └── ProxyRepositoryScope (InheritedNotifier<SingboxProxyRepository>)
        └── MaterialApp.router
              └── GoRouter → ShellRoute → AppShell → [child pages]
```

- `ProxyRepositoryScope.of(context)` 获取仓库实例
- 仓库继承 `ChangeNotifier`，通过 `addListener` / `removeListener` 驱动重建
- 管理：核心生命周期（load/init/start/stop/reload）、配置 JSON、流量统计

### 局部状态：Feature Controllers（ChangeNotifier + AnimatedBuilder）

每个功能页面在 `initState` 中创建自己的 Controller：

```dart
// proxies_page.dart
late final ProxiesController _controller;

@override
void initState() {
  super.initState();
  _controller = ProxiesController()..loadDemoGroups();
}

@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      // 使用 _controller.state 构建 UI
    },
  );
}
```

| Controller | 管理的状态 | 依赖的 Model |
|-----------|----------|-------------|
| `ProxiesController` | mode, groups, selectedGroupIndex, searchQuery, sortAsc, testing | `ProxyGroup`, `ProxyNode` |
| `SubscriptionsController` | subscriptions list | `Subscription` |
| `LogsController` | entries, levelFilter, searchQuery, paused | `LogEntry`, `LogLevel` |
| `SettingsController` | settings (AppSettings) | `AppSettings` |

### 状态流向

```
Controller (ChangeNotifier)
  │
  ├── notifyListeners()
  │
  ▼
AnimatedBuilder (rebuilds child subtree)
  │
  ▼
StatelessWidget tree (pure function of state)
```

**关键原则：** Widget 不直接持有可变状态。页面通过 Controller 读取状态，通过调用 Controller 方法修改状态。Controller 调用 `notifyListeners()` 触发 `AnimatedBuilder` 重建。

---

## 导航结构

### 路由表

```dart
enum AppRoute {
  home('/'),
  proxies('/proxies'),
  subscriptions('/subscriptions'),
  logs('/logs'),
  settings('/settings');
}
```

### ShellRoute 嵌套

```
GoRouter
  └── ShellRoute → AppShell（持久化导航壳）
        ├── /              → HomePage
        ├── /proxies       → ProxiesPage
        ├── /subscriptions → SubscriptionsPage
        ├── /logs          → LogsPage
        └── /settings      → SettingsPage
```

所有页面路由都嵌套在同一个 `ShellRoute` 下，`AppShell` 在路由切换时保持不销毁（导航状态持久化）。

### 自适应布局

```dart
// app_shell.dart
LayoutBuilder(
  builder: (context, constraints) {
    final useRail = constraints.maxWidth >= 720;
    if (useRail) {
      // NavigationRail（左侧）+ VerticalDivider + Expanded(child)
    }
    // NavigationBar（底部）+ Scaffold(body: child)
  },
)
```

| 宽度 | 导航模式 | 位置 |
|------|---------|------|
| < 720px | `NavigationBar` | 底部 |
| >= 720px | `NavigationRail` | 左侧 |

### 5 个一级导航 Tab

| Index | 路由 | 图标 | 标签 |
|-------|------|------|------|
| 0 | `/` | `Icons.home` | Home |
| 1 | `/proxies` | `Icons.hub` | Proxies |
| 2 | `/subscriptions` | `Icons.rss_feed` | Subs |
| 3 | `/logs` | `Icons.receipt_long` | Logs |
| 4 | `/settings` | `Icons.settings` | Settings |

---

## 数据模型设计

所有模型遵循相同模式：

```dart
@immutable
class ModelName {
  const ModelName({
    required this.id,
    // ... 其他字段
  });

  final String id;
  // ... 其他字段

  ModelName copyWith({
    String? id,
    // ...
  }) {
    return ModelName(
      id: id ?? this.id,
      // ...
    );
  }
}
```

### 模型关系

```
Subscription
  ├── id, name, url
  ├── uploadBytes, downloadBytes, totalBytes  (流量)
  ├── lastUpdatedAt, expiresAt                (时间)
  ├── nodeCount, enabled
  └── usagePercent, isExpired                 (计算属性)

ProxyGroup
  ├── id, name, type ("url-test" | "select")
  ├── selectedNodeId?
  ├── nodes: List<ProxyNode>
  └── selectedNode                            (计算属性)

ProxyNode
  ├── id, name, type ("ss" | "vmess" | "trojan" | "direct")
  ├── countryCode?, latencyMs?
  ├── isSelected, isAvailable
  └── metadata: Map<String, dynamic>

LogEntry
  ├── time (DateTime), level (LogLevel)
  ├── source, message
  └── timeString                              (计算属性)

AppSettings
  ├── themeMode (ThemeModeOption)
  ├── startOnBoot, enableNotifications
  ├── listenAddress, mixedPort
  ├── ipv6, systemProxy, perAppProxy
  └── copyWith()

TrafficSnapshot
  ├── uploadBytes, downloadBytes, activeConnections
  ├── totalBytes                              (计算属性)
  └── static zero
```

---

## 主题系统

### 定义

```dart
// core/theme/app_theme.dart
class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xff2563eb),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    // InputDecorationTheme, CardThemeData
  );

  static final dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xff2563eb),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    // InputDecorationTheme, CardThemeData
  );
}
```

### 切换机制

```dart
// lithenet_app.dart
ThemeMode _themeMode = ThemeMode.system;

MaterialApp.router(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: _themeMode,
)

// SettingsController.setThemeMode() → setState → MaterialApp rebuilds
```

### 语义颜色

```dart
// core/theme/app_colors.dart
AppColors.success    // #16a34a  已连接 / 延迟优秀
AppColors.warning    // #d97706  权限缺失 / 配置警告
AppColors.error      // #dc2626  连接失败 / 核心错误
AppColors.upload     // #7c3aed  上传
AppColors.download   // #2563eb  下载
```

### 间距常量

```dart
// core/theme/app_spacing.dart
AppSpacing.pageMargin      // 16dp
AppSpacing.cardPadding     // 16dp
AppSpacing.cardRadius      // 20dp
AppSpacing.sectionGap      // 16dp
AppSpacing.itemGap         // 12dp
AppSpacing.smallGap        // 8dp
AppSpacing.buttonHeight    // 56dp
AppSpacing.maxContentWidth // 1200dp (桌面端)
```

---

## 页面设计规范

### 首页（HomePage）

```
SliverAppBar
  └── "LitheNet"

CustomScrollView
  ├── CurrentProfileCard      连接状态 + 端口 + 监听地址
  ├── ConnectionButton        200x200 圆形大按钮（Connect/Disconnect）
  ├── TrafficStatsCard        上传速度 + 下载速度（彩色卡片）
  ├── QuickActionsGrid        2x2 网格（Test Latency / Change Node / Update Sub / View Logs）
  └── ConnectionErrorBanner   错误时显示，点击跳转日志页
```

### 代理页（ProxiesPage）

```
AppBar("Proxies") + 搜索/排序按钮

Column
  ├── ModeSelector           SegmentedButton (Rule / Global / Direct)
  ├── ProxyGroupTabs         横向 ChoiceChip 列表
  └── Expanded(ListView)     ProxyNodeTile 列表
        └── FAB              测速按钮（SpeedTestFab）
```

### 订阅页（SubscriptionsPage）

```
AppBar("Subscriptions") + 添加按钮

ListView / EmptyState
  └── SubscriptionCard       名称 + Active 标签 + 节点数 + 流量条 + 到期时间 + PopupMenu

AddSubscriptionSheet (BottomSheet)
  ├── 名称输入（可选）
  ├── URL 输入（必填 + 验证）
  ├── 粘贴按钮
  └── 添加按钮
```

### 日志页（LogsPage）

```
AppBar("Logs") + 复制/导出/清空

Column
  ├── LogToolbar             暂停按钮 + 搜索框 + 等级过滤 SegmentedButton
  └── Expanded(ListView)     LogLineTile 列表
        └── 时间 [等级] 来源 消息
```

### 设置页（SettingsPage）

```
AppBar("Settings")

ListView
  ├── GENERAL 分组
  │   ├── Language
  │   ├── Start on boot (Switch)
  │   └── Notifications (Switch)
  ├── NETWORK 分组
  │   ├── Mixed port (点击编辑)
  │   ├── IPv6 (Switch)
  │   └── System proxy (Switch + 重连提示)
  ├── APPEARANCE 分组
  │   └── Theme (System/Light/Dark)
  └── ABOUT 分组
      ├── Version
      ├── Check for updates
      ├── License
      └── Diagnostics
```

---

## 文件依赖关系

```
main.dart
  └── lithenet_app.dart
        ├── app_theme.dart
        ├── proxy_repository.dart ──→ singbox_ffi
        └── router.dart
              ├── home_page.dart ──→ proxy_repository, app_spacing, format_bytes
              ├── proxies_page.dart ──→ proxies_controller, app_spacing, empty_state
              │     └── widgets/ ──→ proxy_group.dart, proxy_node.dart, app_spacing
              ├── subscriptions_page.dart ──→ subscriptions_controller, empty_state
              │     └── widgets/ ──→ subscription.dart, format_bytes, app_spacing
              ├── logs_page.dart ──→ logs_controller, empty_state
              │     └── widgets/ ──→ log_entry.dart
              ├── settings_page.dart ──→ settings_controller, app_settings.dart
              └── app_shell.dart ──→ router.dart (AppRoute)
```

**依赖方向：** UI → Controller → Model → Repository → Native

**禁止反向依赖：** Widget 不直接调用 native bridge，必须通过 Repository/Controller 层。

---

## 关键设计决策

| 决策 | 选择 | 原因 |
|------|------|------|
| 状态管理 | ChangeNotifier + AnimatedBuilder | 零依赖，与现有 ProxyRepository 模式一致 |
| 路由 | go_router ShellRoute | 导航状态持久化，切换页面不重建 |
| 布局 | LayoutBuilder 自适应 | 单代码库支持手机/平板/桌面 |
| 数据模型 | @immutable + copyWith | 纯净不可变，易于追踪变更 |
| 主题 | ColorScheme.fromSeed | 统一色调，light/dark 一键切换 |
| 导航粒度 | 5 个一级 Tab | 首页简单，二级页面专业，高级功能下沉 |

---

## 当前限制与后续方向

### 当前限制

1. **无持久化层** — 所有状态（订阅、设置、代理组）在重启后丢失
2. **Mock 流量** — 上传/下载速度是 Timer 模拟值，非真实 singbox 流量
3. **Mock 节点数据** — 代理页使用硬编码 demo 数据
4. **Settings 未联动 ProxyRepository** — 设置页的端口/IP 修改不传递到核心
5. **子页面未路由** — Settings 的子页面（General/Network/Appearance/About）是内联展示，未配置独立路由

### 后续方向

1. 引入 `shared_preferences` 或 `hive` 做本地持久化
2. 接入真实 singbox 流量统计 API
3. 接入真实订阅解析（HTTP 请求 + YAML/JSON 解析）
4. 添加 `l10n` 国际化支持
5. 实现规则编辑页（可视化 + Raw 模式）
6. 添加备份/恢复功能（文件导出/导入）
7. 桌面端多栏布局（列表 + 详情并排）
