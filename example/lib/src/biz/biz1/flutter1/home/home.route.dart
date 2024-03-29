// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

class HomeRoute extends NavigatorRouteLeaf {
  factory HomeRoute(NavigatorRouteNode parent) =>
      _instance ??= HomeRoute._(parent);

  HomeRoute._(super.parent);

  static HomeRoute? _instance;

  @override
  String get name => 'home';

  /// `strList` hello, this is a list.
  ///
  /// `goodMap` hello, this is a map.
  ///
  /// 测试 集合 传参
  ///
  Future<TPopParams?> push<TPopParams>({
    List<String> strList = const <String>[],
    Map<String, dynamic> goodMap = const <String, dynamic>{},
    bool animated = true,
    NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.push<Map<String, dynamic>, TPopParams>(
        url: url,
        params: <String, dynamic>{
          'strList': strList,
          'goodMap': goodMap,
        },
        animated: animated,
        result: result,
      );

  /// `strList` hello, this is a list.
  ///
  /// `goodMap` hello, this is a map.
  ///
  /// 测试 集合 传参
  ///
  Future<TPopParams?> pushSingle<TPopParams>({
    List<String> strList = const <String>[],
    Map<String, dynamic> goodMap = const <String, dynamic>{},
    bool animated = true,
    NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.pushSingle<Map<String, dynamic>, TPopParams>(
        url: url,
        params: <String, dynamic>{
          'strList': strList,
          'goodMap': goodMap,
        },
        animated: animated,
        result: result,
      );
}
