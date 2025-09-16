// The MIT License (MIT)
//
// Copyright (c) 2025 foxsofter.
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

import '../module/module_anchor.dart';
import 'navigator_page_lifecycle_mixin.dart';
import 'navigator_types.dart';

mixin NavigatorRoutePopToMixin<T extends StatefulWidget>
    on State<T>, NavigatorPageLifecycleMixin<T> {
  /// 拦截路由的 handle，return prevention 表示该路由会被拦截
  ///
  NavigatorRoutePopToHandle get onPopTo;

  VoidCallback? _registry;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _init();
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  void _init() {
    _registry?.call();
    _registry = anchor.popToHandlers.registry(onPopTo);
  }

  @override
  void dispose() {
    _registry?.call();
    super.dispose();
  }
}
