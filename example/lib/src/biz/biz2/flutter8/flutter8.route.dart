// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

class Flutter8Route extends NavigatorRouteLeaf {
  factory Flutter8Route(NavigatorRouteNode parent) =>
      _instance ??= Flutter8Route._(parent);

  Flutter8Route._(super.parent);

  static Flutter8Route? _instance;

  @override
  String get name => 'flutter8';

  Future<TPopParams?> push<TParams, TPopParams>({
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.push<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
      );

  Future<TPopParams?> pushSingle<TParams, TPopParams>({
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.pushSingle<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
      );
}
