import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/password_reset_screen.dart';
import '../../features/orders/presentation/orders_board_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/alarm_overlay_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/menu/presentation/item_editor_screen.dart';
import '../../features/menu/presentation/price_edit_screen.dart';
import '../../features/money/presentation/money_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/reviews/presentation/reviews_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/more/presentation/hours_screen.dart';
import '../../features/more/presentation/staff_screen.dart';
import '../../features/more/presentation/settings_screen.dart';
import '../widgets/shell_scaffold.dart';
import '../providers/auth_state_provider.dart';

/// Route name constants
abstract final class Routes {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const forgotPassword = '/forgot-password';
  static const orders = '/orders';
  static const orderDetail = '/orders/:uuid';
  static const alarm = '/alarm/:uuid';
  static const menu = '/menu';
  static const itemEditor = '/menu/item/:uuid';
  static const priceEdit = '/menu/price/:uuid';
  static const money = '/money';
  static const history = '/history';
  static const reviews = '/reviews';
  static const more = '/more';
  static const hours = '/more/hours';
  static const staff = '/more/staff';
  static const settings = '/more/settings';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.orders,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isOnboarding = authState.needsOnboarding;
      final location = state.matchedLocation;

      if (!isAuth && location != Routes.login) return Routes.login;
      if (isAuth && isOnboarding && location != Routes.onboarding) {
        return Routes.onboarding;
      }
      if (isAuth && location == Routes.login) return Routes.orders;
      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) => const PasswordResetScreen(),
      ),
      // Alarm overlay (full-screen, above shell)
      GoRoute(
        path: Routes.alarm,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => AlarmOverlayScreen(
          orderUuid: state.pathParameters['uuid']!,
        ),
      ),
      // Shell with 4 tabs
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: Routes.orders,
            builder: (_, __) => const OrdersBoardScreen(),
            routes: [
              GoRoute(
                path: ':uuid',
                builder: (_, state) => OrderDetailScreen(
                  uuid: state.pathParameters['uuid']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.menu,
            builder: (_, __) => const MenuScreen(),
            routes: [
              GoRoute(
                path: 'item/:uuid',
                builder: (_, state) => ItemEditorScreen(
                  uuid: state.pathParameters['uuid']!,
                ),
              ),
              GoRoute(
                path: 'price/:uuid',
                builder: (_, state) => PriceEditScreen(
                  uuid: state.pathParameters['uuid']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.money,
            builder: (_, __) => const MoneyScreen(),
          ),
          GoRoute(
            path: Routes.more,
            builder: (_, __) => const MoreScreen(),
            routes: [
              GoRoute(path: 'hours', builder: (_, __) => const HoursScreen()),
              GoRoute(path: 'staff', builder: (_, __) => const StaffScreen()),
              GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
              GoRoute(
                path: 'history',
                builder: (_, __) => const HistoryScreen(),
              ),
              GoRoute(
                path: 'reviews',
                builder: (_, __) => const ReviewsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
