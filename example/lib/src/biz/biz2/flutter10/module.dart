// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter10.page.dart';

class Module with ThrioModule, ModulePageBuilder {
  @override
  String get key => 'flutter10';

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) =>
      pageBuilder = (settings) => Flutter10Page(
            moduleContext: moduleContext,
            settings: settings,
          );
}
