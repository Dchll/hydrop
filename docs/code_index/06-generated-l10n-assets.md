# 生成代码、本地化和资源

## Drift 生成文件

`lib/data/local/database.g.dart` 是 Drift 根据表和 DAO 生成的数据库实现，包含表信息、Companion、DataClass、查询管理器和 DAO mixin。它让手写 DAO 可以访问 `deviceItems`、`messageItems` 等 typed table，并把 SQL 查询结果映射成 Dart row 对象。

`lib/data/local/dao/*.g.dart` 是 Drift accessor mixin，负责把手写 DAO 和数据库表连接起来。它们不承载业务逻辑，业务逻辑在对应 `.dart` DAO 文件里。

## Riverpod 生成文件

`lib/data/local/database_providers.g.dart`、`dao_providers.g.dart`、各 repository `.g.dart`、`dio_provider.g.dart`、`bing_wallpaper_repository.g.dart` 是 Riverpod generator 产物。它们把 `@Riverpod` 函数转换为强类型 provider、family 参数对象、hash、override 支持和 element 类型。

调用方使用 `xxxProvider`，不直接实例化生成类。新增或修改 `@Riverpod` 函数后应通过 build_runner 重新生成。

## AutoRoute 生成文件

`lib/routes/app_router.gr.dart` 把 `@RoutePage()` 页面生成成 `HomeRoute`、`SettingsRoute`、`ChatRoute`、`AppRoute` 等 route class。它负责保存页面参数，例如 `ChatRoute(remoteDeviceId, displayName, showBackButton)`，并在导航时创建对应页面。

## FlutterGen 资源

`lib/gen/assets.gen.dart`、`colors.gen.dart`、`fonts.gen.dart` 是 FlutterGen 产物。当前项目主要使用 `ColorName` 作为主题和反馈组件的颜色来源；字体 family 在 `AppTheme.fontFamily` 中写为 MiSans。

## 本地化生成代码与 ARB

`lib/gen/l10n/app_localizations.dart` 是 Flutter gen-l10n 的抽象基类和 lookup 入口，定义所有本地化 getter/method、delegate、supportedLocales 和 locale lookup。

`app_localizations_en.dart`、`app_localizations_zh.dart` 是英文和中文实现。它们把 ARB 键转换为具体字符串和插值方法。繁体 ARB 存在于 `lib/l10n/app_zh_Hant.arb`，生成时由 gen-l10n 根据配置处理。

`lib/l10n/*.arb` 是用户可见文案源。页面里的标题、按钮、状态、单位、通知文案、错误提示都应从这里取；业务格式化统一经 `localized_formatters.dart`。

## 生成文件维护规则

- 不手改 `*.g.dart`、`app_router.gr.dart`、`lib/gen/*`。
- 路由变化改页面注解和 `app_router.dart` 后生成。
- Provider/DAO/Drift 变化改源文件后运行 build_runner。
- 文案变化改 ARB 后运行 `flutter gen-l10n`。
