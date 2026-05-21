import 'package:flutter/widgets.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';

extension AppLanguageX on AppLanguage {
  Locale? get locale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.en => const Locale('en'),
      AppLanguage.zhHans => const Locale('zh'),
      AppLanguage.zhHant => const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      ),
    };
  }
}
