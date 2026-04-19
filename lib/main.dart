import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/src/core/network/http_client.dart';
import 'package:wallet/src/core/theme/theme_provider.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/auth/presentation/pages/register_page.dart';
import 'package:wallet/src/features/auth/repository/auth_repository.dart';
import 'src/features/main/presentation/pages/main_tabs.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(ProviderScope(child: const MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  DateTime? _lastPausedTime;
  final _sessionTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    // Set this ONCE, not every build
    HttpClient.onUnauthorized = () {
      ref.read(userProvider.notifier).logout();
    };
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .paused) {
      _lastPausedTime = DateTime.now();
    } else if (state == .resumed) {
      if (_lastPausedTime != null) {
        final pausedDuration = DateTime.now().difference(_lastPausedTime!);
        if (pausedDuration > _sessionTimeout) {
          debugPrint(
            'App resumed after ${pausedDuration.inSeconds}s, logging out.',
          );
          AuthRepository().logout();
          // Don't call _redirectToLogin() here - let the error state handle navigation
        } else {
          debugPrint(
            'App resumed after ${pausedDuration.inSeconds}s, session still valid.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final brightness = ref.watch(themeProvider);

    return CupertinoApp(
      navigatorKey: navigatorKey,
      theme: CupertinoThemeData(brightness: brightness),
      home: userAsync.when(
        data: (user) {
          // Only remove splash when we have a real answer
          FlutterNativeSplash.remove();
          return const MainTabs();
        },
        error: (error, stack) {
          FlutterNativeSplash.remove();
          return const RegisterPage();
        },
        // Return an empty container. Since you haven't called .remove(),
        // the Splash Screen stays over the top of the app.
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
