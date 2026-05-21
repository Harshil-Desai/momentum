import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/offline/connectivity_provider.dart';
import 'core/offline/sync_service.dart';
import 'core/api_client.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();
  await NotificationService().init();
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '',
      );
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(const ProviderScope(child: CadenceApp())),
  );
}

class CadenceApp extends ConsumerStatefulWidget {
  const CadenceApp({super.key});

  @override
  ConsumerState<CadenceApp> createState() => _CadenceAppState();
}

class _CadenceAppState extends ConsumerState<CadenceApp>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _notifSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenConnectivity();
    _listenNotificationTaps();
  }

  void _listenNotificationTaps() {
    _notifSub = NotificationService.onTap.listen((payload) {
      if (!mounted) return;
      // Navigate to habits screen; deep-linking to a specific habit detail
      // requires a loaded Habit object, so we land on the habits list instead.
      context.go('/habits');
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onForeground();
    }
  }

  void _onForeground() {
    final auth = ref.read(authProvider).value;
    if (auth == null || !auth.isAuthenticated || auth.userId == null) return;
    final sync = SyncService(ref.read(dioProvider));
    unawaited(
      sync.flush().then((_) => sync.fullRefresh(auth.userId!)),
    );
  }

  void _listenConnectivity() {
    ref.listenManual(connectivityProvider, (_, next) {
      if (next.value == true) {
        final auth = ref.read(authProvider).value;
        if (auth != null && auth.isAuthenticated) {
          unawaited(ref.read(syncManagerProvider.notifier).flush());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Cadence',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
