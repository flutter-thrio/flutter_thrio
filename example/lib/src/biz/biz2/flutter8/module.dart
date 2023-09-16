// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter8.page.dart';

class Module with ThrioModule, ModulePageBuilder {
  @override
  String get key => 'flutter8';

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) =>
      pageBuilder = (settings) => Flutter8Page(
            moduleContext: moduleContext,
            settings: settings,
          );
}
