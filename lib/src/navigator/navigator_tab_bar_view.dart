import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'navigator_page_view.dart';

/// A page view that displays the widget which corresponds to the currently
/// selected tab.
///
/// This widget is typically used in conjunction with a [TabBar].
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=POtoEH-5l40}
///
/// If a [TabController] is not provided, then there must be a [DefaultTabController]
/// ancestor.
///
/// The tab controller's [TabController.length] must equal the length of the
/// [children] list and the length of the [TabBar.tabs] list.
///
/// To see a sample implementation, visit the [TabController] documentation.
class NavigatorTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const NavigatorTabBarView({
    super.key,
    required this.routeSettings,
    this.keepIndex = false,
    this.childBuilder,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
    this.viewportFraction = 1.0,
    this.clipBehavior = Clip.hardEdge,
  });

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController? controller;

  /// One RouteSettings per tab.
  ///
  /// Its length must match the length of the [TabBar.tabs]
  /// list, as well as the [controller]'s [TabController.length].
  final List<RouteSettings> routeSettings;

  final bool keepIndex;

  final Widget Function(
    BuildContext context,
    RouteSettings settings,
    Widget child,
  )? childBuilder;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.pageview.viewportFraction}
  final double viewportFraction;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  State<NavigatorTabBarView> createState() => _NavigatorTabBarViewState();
}

class _NavigatorTabBarViewState extends State<NavigatorTabBarView> {
  TabController? _controller;
  PageController? _pageController;
  List<Widget>? _childrenWithKey;
  int? _currentIndex;
  int _warpUnderwayCount = 0;
  int _scrollUnderwayCount = 0;
  bool _debugHasScheduledValidChildrenCountCheck = false;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

  void _updateTabController() {
    final newController =
        widget.controller ?? DefaultTabController.maybeOf(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
          'No TabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must either provide an explicit '
          'TabController using the "controller" property, or you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.\n'
          'In this case, there was neither an explicit controller nor a default controller.',
        );
      }
      return true;
    }());

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = newController;
    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
    }
  }

  void _jumpToPage(int page) {
    _warpUnderwayCount += 1;
    _pageController!.jumpToPage(page);
    _warpUnderwayCount -= 1;
  }

  Future<void> _animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) async {
    _warpUnderwayCount += 1;
    await _pageController!
        .animateToPage(page, duration: duration, curve: curve);
    _warpUnderwayCount -= 1;
  }

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _currentIndex = _controller!.index;
    if (_pageController == null) {
      _pageController = PageController(
        initialPage: _currentIndex!,
        viewportFraction: widget.viewportFraction,
      );
    } else {
      _pageController!.jumpToPage(_currentIndex!);
    }
  }

  @override
  void didUpdateWidget(NavigatorTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
      _currentIndex = _controller!.index;
      _jumpToPage(_currentIndex!);
    }
    if (widget.viewportFraction != oldWidget.viewportFraction) {
      _pageController?.dispose();
      _pageController = PageController(
        initialPage: _currentIndex!,
        viewportFraction: widget.viewportFraction,
      );
    }
    // While a warp is under way, we stop updating the tab page contents.
    // This is tracked in https://github.com/flutter/flutter/issues/31269.
    if (widget.routeSettings != oldWidget.routeSettings &&
        _warpUnderwayCount == 0) {
      _updateChildren();
    }
  }

  @override
  void dispose() {
    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = null;
    _pageController?.dispose();
    // We don't own the _controller Animation, so it's not disposed here.
    super.dispose();
  }

  void _updateChildren() {
    if (pv != null && pv?.children != null) {
      _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(pv!.children!);
    } else {
      // 尽可能早的初始化
      Future.delayed(const Duration(milliseconds: 10), _updateChildren);
    }
  }

  void _handleTabControllerAnimationTick() {
    if (_scrollUnderwayCount > 0 || !_controller!.indexIsChanging) {
      return;
    } // This widget is driving the controller's animation.

    if (_controller!.index != _currentIndex) {
      _currentIndex = _controller!.index;
      _warpToCurrentIndex();
    }
  }

  void _warpToCurrentIndex() {
    if (!mounted || _pageController!.page == _currentIndex!.toDouble()) {
      return;
    }

    final adjacentDestination =
        (_currentIndex! - _controller!.previousIndex).abs() == 1;
    if (adjacentDestination) {
      _warpToAdjacentTab(_controller!.animationDuration);
    } else {
      _warpToNonAdjacentTab(_controller!.animationDuration);
    }
  }

  Future<void> _warpToAdjacentTab(Duration duration) async {
    if (duration == Duration.zero) {
      _jumpToPage(_currentIndex!);
    } else {
      await _animateToPage(_currentIndex!,
          duration: duration, curve: Curves.ease);
    }
    if (mounted) {
      setState(_updateChildren);
    }
    return Future<void>.value();
  }

  Future<void> _warpToNonAdjacentTab(Duration duration) async {
    final previousIndex = _controller!.previousIndex;
    assert((_currentIndex! - previousIndex).abs() > 1);

    // initialPage defines which page is shown when starting the animation.
    // This page is adjacent to the destination page.
    final initialPage = _currentIndex! > previousIndex
        ? _currentIndex! - 1
        : _currentIndex! + 1;

    setState(() {
      // Needed for `RenderSliverMultiBoxAdaptor.move` and kept alive children.
      // For motivation, see https://github.com/flutter/flutter/pull/29188 and
      // https://github.com/flutter/flutter/issues/27010#issuecomment-486475152.
      if (_childrenWithKey == null) {
        return;
      }
      _childrenWithKey = List<Widget>.of(_childrenWithKey!, growable: false);
      final temp = _childrenWithKey![initialPage];
      _childrenWithKey![initialPage] = _childrenWithKey![previousIndex];
      _childrenWithKey![previousIndex] = temp;
    });

    // Make a first jump to the adjacent page.
    _jumpToPage(initialPage);

    // Jump or animate to the destination page.
    if (duration == Duration.zero) {
      _jumpToPage(_currentIndex!);
    } else {
      await _animateToPage(_currentIndex!,
          duration: duration, curve: Curves.ease);
    }

    if (mounted) {
      setState(_updateChildren);
    }
  }

  void _syncControllerOffset() {
    _controller!.offset =
        clampDouble(_pageController!.page! - _controller!.index, -1.0, 1.0);
  }

  // Called when the PageView scrolls
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_warpUnderwayCount > 0 || _scrollUnderwayCount > 0) {
      return false;
    }

    if (notification.depth != 0) {
      return false;
    }

    if (!_controllerIsValid) {
      return false;
    }

    _scrollUnderwayCount += 1;
    final page = _pageController!.page!;
    if (notification is ScrollUpdateNotification &&
        !_controller!.indexIsChanging) {
      final pageChanged = (page - _controller!.index).abs() > 1.0;
      if (pageChanged) {
        _controller!.index = page.round();
        _currentIndex = _controller!.index;
      }
      _syncControllerOffset();
    } else if (notification is ScrollEndNotification) {
      _controller!.index = page.round();
      _currentIndex = _controller!.index;
      if (!_controller!.indexIsChanging) {
        _syncControllerOffset();
      }
    }
    _scrollUnderwayCount -= 1;

    return false;
  }

  bool _debugScheduleCheckHasValidChildrenCount() {
    if (_debugHasScheduledValidChildrenCountCheck) {
      return true;
    }
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _debugHasScheduledValidChildrenCountCheck = false;
      if (!mounted) {
        return;
      }
      assert(() {
        if (_controller!.length != widget.routeSettings.length) {
          throw FlutterError(
            "Controller's length property (${_controller!.length}) does not match the "
            "number of children (${widget.routeSettings.length}) present in TabBarView's children property.",
          );
        }
        return true;
      }());
    }, debugLabel: 'NavigatorTabBarView.validChildrenCountCheck');
    _debugHasScheduledValidChildrenCountCheck = true;
    return true;
  }

  NavigatorPageView? pv;

  @override
  Widget build(BuildContext context) {
    assert(_debugScheduleCheckHasValidChildrenCount());
    pv = NavigatorPageView(
      dragStartBehavior: widget.dragStartBehavior,
      clipBehavior: widget.clipBehavior,
      controller: _pageController,
      physics: widget.physics == null
          ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
          : const PageScrollPhysics().applyTo(widget.physics),
      routeSettings: widget.routeSettings,
    );
    // must invoke to update `_childrenWithKey` once the building process is completed.
    Future(_updateChildren);
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: pv!,
    );
  }
}
