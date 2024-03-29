// Copyright (c) 2022 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

import 'biz/module.dart' as biz;

class Module
    with
        ThrioModule,
        ModuleJsonDeserializer,
        ModuleJsonSerializer,
        ModuleParamScheme {
  @override
  void onModuleRegister(ModuleContext moduleContext) {
    navigatorLogEnabled = true;
    registerModule(biz.Module(), moduleContext);
  }

  @override
  void onParamSchemeRegister(ModuleContext moduleContext) {}

  @override
  void onJsonSerializerRegister(ModuleContext moduleContext) {}

  @override
  void onJsonDeserializerRegister(ModuleContext moduleContext) {}
}
