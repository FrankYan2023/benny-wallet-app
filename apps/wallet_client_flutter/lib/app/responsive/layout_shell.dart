import 'package:flutter/widgets.dart';

class LayoutShell extends StatelessWidget {
  const LayoutShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.title,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
