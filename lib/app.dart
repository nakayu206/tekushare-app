import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/pages/account_link/view/accept_invite_page.dart';
import 'package:tekushare/screens/pages/auth/view/display_name_page.dart';
import 'package:tekushare/screens/pages/auth/view/email_auth_page.dart';
import 'package:tekushare/screens/pages/auth/view/password_set_page.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/providers/account_link_provider.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();
final navigatorKey = GlobalKey<NavigatorState>();

/// アプリのルートWidget
class TekuShareApp extends ConsumerStatefulWidget {
  const TekuShareApp({super.key});

  @override
  ConsumerState<TekuShareApp> createState() => _TekuShareAppState();
}

class _TekuShareAppState extends ConsumerState<TekuShareApp> {
  final _appLinks = AppLinks();

  // getInitialLink() と uriLinkStream の両方から同じ起動時リンクが
  // 届くことがあるため、処理済みトークンを覚えて二重に画面を開かないようにする。
  final _handledTokens = <String>{};

  @override
  void initState() {
    super.initState();
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri);
    });
    _appLinks.uriLinkStream.listen(_handleUri);
  }

  /// ディープリンクを受け取り、種別に応じて画面遷移する。
  /// 対応スキーム:
  ///   - https://tekushare.web.app/__/auth/action?mode=resetPassword&oobCode=...
  ///   - tekushare://link/<token>
  ///   - https://tekushare.web.app/link/<token>
  void _handleUri(Uri uri) {
    if (_isPasswordResetAction(uri)) {
      final oobCode = uri.queryParameters['oobCode']!;
      if (!_handledTokens.add('reset:$oobCode')) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => PasswordSetPage(oobCode: oobCode)),
      );
      return;
    }

    final token = _extractToken(uri);
    if (token == null) return;
    if (!_handledTokens.add(token)) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null && user.displayName?.isNotEmpty == true) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => AcceptInvitePage(token: token)),
      );
    } else {
      ref.read(pendingInviteTokenProvider.notifier).state = token;
    }
  }

  bool _isPasswordResetAction(Uri uri) {
    return uri.scheme == 'https' &&
        uri.host == 'tekushare.web.app' &&
        uri.path.startsWith('/__/auth/action') &&
        uri.queryParameters['mode'] == 'resetPassword' &&
        uri.queryParameters['oobCode'] != null;
  }

  String? _extractToken(Uri uri) {
    if (uri.scheme == 'tekushare' && uri.host == 'link') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.scheme == 'https' &&
        uri.host == 'tekushare.web.app' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'link') {
      return uri.pathSegments[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ready = ref.watch(appReadyProvider);
    final authState = ref.watch(authStateProvider);

    ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user == null || user.displayName == null || user.displayName == '') {
        return;
      }
      final token = ref.read(pendingInviteTokenProvider);
      if (token == null) return;
      ref.read(pendingInviteTokenProvider.notifier).state = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => AcceptInvitePage(token: token)),
        );
      });
    });

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.zenMaruGothicTextTheme(),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final sw = MediaQuery.sizeOf(context).width;
        return Theme(
          data: Theme.of(context).copyWith(
            extensions: [AppSizingTheme.fromScreenWidth(sw)],
          ),
          child: child!,
        );
      },
      home: ready.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('DB初期化エラー: $e'))),
        data: (_) => authState.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('認証エラー: $e'))),
          data: (user) {
            if (user == null) return const EmailAuthPage();
            final name = user.displayName;
            // null は Firebase がプロフィールを同期中の一時状態。
            // ローディングを挟み DisplayNamePage が誤表示されるのを防ぐ。
            if (name == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (name.isEmpty) return const DisplayNamePage();
            return const HomePage();
          },
        ),
      ),
    );
  }
}
