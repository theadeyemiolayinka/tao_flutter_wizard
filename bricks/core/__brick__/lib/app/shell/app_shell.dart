import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// Base shell for the app's primary navigation scaffold.
///
/// Place persistent chrome here: bottom nav bars, side rails, drawers,
/// etc. Shells compose multiple feature routes into a single visual container.
///
/// See also:
/// - [StatefulShellRoute] from go_router for nested navigation shells
/// - `app/shell/` directory for specialised shell variants
///
/// Usage with GoRouter:
/// ```dart
/// StatefulShellRoute.indexedStack(
///   builder: (context, state, child) => AppShell(child: child),
///   branches: [...],
/// )
/// ```
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}

/// A shell with a bottom navigation bar.
///
/// Extend or replace [destinations] to match your app's navigation structure.
///
/// ```dart
/// StatefulShellRoute.indexedStack(
///   builder: (context, state, navigationShell) =>
///       BottomNavShell(navigationShell: navigationShell),
///   branches: [...],
/// )
/// ```
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: destinations,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

/// A shell with a side navigation rail (for tablet/desktop layouts).
class SideNavShell extends StatelessWidget {
  const SideNavShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.trailing,
    this.header,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavigationRailDestination> destinations;
  final Widget? trailing;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: destinations,
            labelType: NavigationRailLabelType.all,
            leading: header,
            trailing: trailing,
            minWidth: 80,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

/// An adaptive shell that switches between [BottomNavShell] (mobile) and
/// [SideNavShell] (tablet/desktop) based on screen width.
class AdaptiveNavShell extends StatelessWidget {
  const AdaptiveNavShell({
    super.key,
    required this.navigationShell,
    required this.bottomDestinations,
    required this.railDestinations,
    this.railHeader,
    this.railTrailing,
    this.breakpoint = 600,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> bottomDestinations;
  final List<NavigationRailDestination> railDestinations;
  final Widget? railHeader;
  final Widget? railTrailing;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= breakpoint) {
      return SideNavShell(
        navigationShell: navigationShell,
        destinations: railDestinations,
        header: railHeader,
        trailing: railTrailing,
      );
    }

    return BottomNavShell(
      navigationShell: navigationShell,
      destinations: bottomDestinations,
    );
  }
}
