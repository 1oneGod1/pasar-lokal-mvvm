import 'package:flutter/widgets.dart';

class HomeTabScope extends InheritedWidget {
  const HomeTabScope({
    super.key,
    required this.onSelectTab,
    required super.child,
  });

  final ValueChanged<int> onSelectTab;

  static HomeTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeTabScope>();
  }

  @override
  bool updateShouldNotify(HomeTabScope oldWidget) {
    return oldWidget.onSelectTab != onSelectTab;
  }
}
