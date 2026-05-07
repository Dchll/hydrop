# Drift + Riverpod 数据层落地计划

## 目标

- 数据库细节只保留在 `lib/data` 层，页面和业务 UI 不直接操作 Drift。
- 以 Drift 作为本地持久化 Single Source of Truth。
- 以 Riverpod 负责依赖注入、响应式读取和测试 override。
- 外部代码通过 Repository 和业务 provider 读写数据，不感知表、SQL、DAO 或 Companion。

## 分层职责

### Database Provider

- `appDataBaseProvider` 是底层数据库单例，使用 `keepAlive`。
- provider 创建 `AppDataBase` 后注册 `ref.onDispose(db.close)`。
- 除 DAO 和 Repository 外，其他代码不直接读取该 provider。

### DAO 层

- 目录：`lib/data/dao`。
- DAO 只处理 Drift 查询、事务、批量写入和表关联。
- DAO 可以返回 Drift row，但不暴露给 UI。
- 跨表原子操作使用 Drift `transaction`。

### Repository 层

- 目录：`lib/data/repository`。
- Repository 是 data 层对外主入口。
- Repository 暴露业务语义方法，例如：
  - `watchDevices()`
  - `saveDiscoveredDevice()`
  - `watchConversation()`
  - `sendTextMessage()`
  - `setThemeMode()`
- Repository 不向 UI 暴露 `AppDataBase`、`Table`、`Companion`、`Selectable`。

### Riverpod 查询层

- Repository 使用普通 provider 暴露，例如 `deviceRepositoryProvider`。
- 响应式读取使用 stream provider，例如 `deviceListProvider`。
- 带参数查询使用 family，例如 `conversationProvider(remoteDeviceId)`。
- 参数化 provider 默认 auto-dispose，避免会话参数缓存长期残留。

## 命名约定

- 底层数据库：`appDataBaseProvider`
- DAO：`deviceDaoProvider`
- Repository：`deviceRepositoryProvider`
- 查询状态：`deviceListProvider`、`conversationProvider`、`settingsProvider`

## 使用约束

- UI 不 import `lib/data/local/database.dart`。
- UI 不直接调用 Drift 的 `select`、`into`、`update`、`delete`。
- 新增数据库能力时，优先按 Table -> DAO -> Repository -> Provider 的顺序扩展。
- 如果 UI 需要稳定类型，Repository 返回 domain/view model，而不是 Drift 生成类型。

## 测试策略

- Repository/Provider 测试使用内存数据库 override `appDataBaseProvider`。
- 测试应覆盖：
  - 插入设备后 `deviceListProvider` 发出新列表。
  - 插入消息和附件后 `conversationProvider(remoteDeviceId)` 返回完整会话。
  - 设置更新后 `settingsProvider` 发出新值。
  - UI 不再直接依赖 Drift 数据库入口。

## 验证命令

```sh
flutter pub run build_runner build --delete-conflicting-outputs
dart format lib/data lib/presentation/pages/home/home_page.dart test
flutter test
flutter analyze
```
