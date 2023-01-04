// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'package:flutter/widgets.dart';

import '../exception/thrio_exception.dart';
import '../extension/thrio_dynamic.dart';
import '../extension/thrio_iterable.dart';
import '../module/thrio_module.dart';
import 'navigator_material_app.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

mixin NavigatorPage {
  ModuleContext get moduleContext;

  dynamic get params;

  String get url;

  int get index;

  /// Get parameter from params, throw ArgumentError when`key`'s value  not found .
  ///
  T getParam<T>(final String key) => getValue(params, key);

  /// Get parameter from params, return `defaultValue` when`key`'s value  not found .
  ///
  T getParamOrDefault<T>(final String key, final T defaultValue) =>
      getValueOrDefault(params, key, defaultValue);

  /// Get parameter from params.
  ///
  T? getParamOrNull<T>(final String key) => getValueOrNull(params, key);

  List<E> getListParam<E>(final String key) => getListValue<E>(params, key);

  Map<K, V> getMapParam<K, V>(final String key) =>
      getMapValue<K, V>(params, key);

  /// Get moduleContext from current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time.
  ///
  static ModuleContext moduleContextOf(
    final BuildContext context, {
    final bool rootModuleContext = false,
  }) {
    final page = of(context, rootModuleContext: rootModuleContext);
    if (page != null) {
      return page.moduleContext;
    }
    // 触发兜底逻辑
    final widget = context.widget;
    if (widget is NavigatorMaterialApp) {
      return widget.moduleContext;
    }
    NavigatorMaterialApp? app;
    context.visitAncestorElements((final it) {
      final widget = it.widget;
      if (widget is NavigatorMaterialApp) {
        app = widget;
        return false;
      }
      return true;
    });
    if (app == null) {
      throw ThrioException('no moduleContext on the app');
    }
    return app!.moduleContext;
  }

  /// Get params of current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time.
  ///
  static dynamic paramsOf(
    final BuildContext context, {
    final bool rootModuleContext = false,
  }) =>
      of(context, rootModuleContext: rootModuleContext)?.params ??
      (throw ThrioException('no params on the page'));

  /// Get url of current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time.
  ///
  static String urlOf(
    final BuildContext context, {
    final bool rootModuleContext = false,
  }) =>
      of(context, rootModuleContext: rootModuleContext)?.url ??
      (throw ThrioException('no url on the page'));

  /// Get index of current page.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time.
  ///
  static int indexOf(
    final BuildContext context, {
    final bool rootModuleContext = false,
  }) =>
      of(context, rootModuleContext: rootModuleContext)?.index ??
      (throw ThrioException('no index on the page'));

  static NavigatorPage? of(
    final BuildContext context, {
    final bool rootModuleContext = false,
  }) {
    final allRoutes = ThrioNavigatorImplement.shared().allFlutterRoutes();
    NavigatorPage? page;
    final widget = context.widget;
    if (widget is NavigatorPage) {
      page = widget as NavigatorPage;
      if (rootModuleContext) {
        if (allRoutes.lastWhereOrNull(
                (final it) => it.url == page?.url && it.index == page?.index) !=
            null) {
          return page;
        }
      } else {
        return page;
      }
      page = null;
    }
    context.visitAncestorElements((final it) {
      final widget = it.widget;
      if (widget is NavigatorPage) {
        page = widget as NavigatorPage;
        if (rootModuleContext) {
          return allRoutes.lastWhereOrNull((final it) =>
                  it.url == page?.url && it.index == page?.index) !=
              null;
        }
        return false;
      }
      return true;
    });
    return page;
  }
}
