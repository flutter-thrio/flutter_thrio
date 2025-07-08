import 'package:flutter/material.dart';

import 'navigator_route.dart';
import 'navigator_types.dart';

class NavigatorPresentRoute extends PageRouteBuilder<bool> with NavigatorRoute {
  NavigatorPresentRoute({
    required NavigatorPageBuilder pageBuilder,
    required RouteSettings settings,
    this.sheetHeight,
    super.transitionDuration,
    super.reverseTransitionDuration,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (_, __, ___) => pageBuilder(settings),
          settings: settings,
          opaque: false,
        );

  final double? sheetHeight;
  final double cornerRadius = 20.0;

  @override
  void addScopedWillPopCallback(WillPopCallback callback) {
    setPopDisabled(disabled: true);
    super.addScopedWillPopCallback(callback);
  }

  @override
  void removeScopedWillPopCallback(WillPopCallback callback) {
    setPopDisabled();
    super.removeScopedWillPopCallback(callback);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 1. 创建底部向上滑入的动画
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    // 2. 创建背景渐变动画
    final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);

    // 3. 获取屏幕尺寸和安全区域
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final safeAreaBottom = mediaQuery.padding.bottom;

    return Stack(
      children: [
        // 半透明背景层（可点击关闭）
        if (barrierDismissible)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(color: barrierColor),
            ),
          ),

        // 内容层
        SlideTransition(
          position: slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight - safeAreaBottom - 44, // 留出顶部空间
              ),
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(cornerRadius),
                    topRight: Radius.circular(cornerRadius),
                  ),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true, // 移除内部组件的顶部padding
                    child: SafeArea(
                      top: false, // 不添加顶部安全区域
                      bottom: false, // 添加底部安全区域
                      maintainBottomViewPadding: true,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
