import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/domain/entities/app_update.dart';
import 'package:tekushare/screens/providers/app_update_provider.dart';

/// Navigator全体を覆い、必須更新中は戻る操作やディープリンクでも迂回させない。
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
  AppUpdate? _update;
  bool _isRequired = false;
  bool _isOpening = false;
  String? _error;
  int _request = 0;

  String _key(AppUpdate update) =>
      'update_seen_${AppConfig.flavor.name}_${Theme.of(context).platform.name}_${update.latestBuild}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _request++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(appUpdateProvider);
  }

  Future<void> _consider(AppUpdate? update) async {
    final request = ++_request;
    if (update == null) return;
    try {
      final build = await ref
          .read(installedBuildLoaderProvider)()
          .timeout(const Duration(seconds: 5));
      if (!mounted || request != _request) return;
      if (!update.isAvailable(build)) {
        setState(() => _update = null);
        return;
      }
      final required = update.isRequired(build);
      final prefs = await SharedPreferences.getInstance();
      if (!mounted || request != _request) return;
      if (!required && prefs.getBool(_key(update)) == true) return;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _update = update;
        _isRequired = required;
        _error = null;
      });
    } catch (e) {
      debugPrint('更新案内の確認に失敗しました: $e');
    }
  }

  Future<void> _dismiss() async {
    final update = _update;
    if (update == null || _isRequired) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      await prefs.setBool(_key(update), true);
      if (mounted) setState(() => _update = null);
    } catch (e) {
      if (mounted) setState(() => _error = '保存できませんでした。もう一度お試しください。');
    }
  }

  Future<void> _openStore() async {
    final update = _update;
    if (update == null || _isOpening) return;
    setState(() {
      _isOpening = true;
      _error = null;
    });
    try {
      if (!await launchUrl(update.storeUri,
          mode: LaunchMode.externalApplication)) {
        throw StateError('ストアを開けませんでした');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'ストアを開けませんでした。もう一度お試しください。');
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appUpdateProvider, (_, next) {
      if (next is AsyncData<AppUpdate?>) unawaited(_consider(next.value));
    });
    ref.watch(appUpdateProvider);
    final update = _update;
    if (update == null) return widget.child;
    return PopScope(
      canPop: false,
      child: Stack(children: [
        ExcludeFocus(
            child: ExcludeSemantics(child: IgnorePointer(child: widget.child))),
        Positioned.fill(
            child: Material(
          color: AppColors.background,
          child: SafeArea(
              child: Center(
                  child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.x3l),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSize.maxContentWidth),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircleAvatar(
                    radius: AppSize.avatarMd,
                    backgroundColor: AppColors.textLight,
                    child: Icon(Icons.system_update_rounded,
                        size: AppSize.iconXl, color: AppColors.primary)),
                const SizedBox(height: AppSpacing.x3l),
                Text(_isRequired ? 'アップデートをお願いします' : '新しいてくしぇあが届きました',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.lg),
                Text(
                    _isRequired
                        ? '安心してお使いいただくために、\n最新バージョンへの更新をお願いします。'
                        : 'てくしぇあを、もっと心地よく。\n最新バージョンに更新してお使いください。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textPrimary, height: 1.8)),
                const SizedBox(height: AppSpacing.lg),
                Text('バージョン ${update.version}',
                    style: const TextStyle(color: AppColors.textAccent)),
                const SizedBox(height: AppSpacing.x3l),
                SizedBox(
                    width: double.infinity,
                    height: AppSize.buttonHeight,
                    child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full))),
                        onPressed: _isOpening ? null : _openStore,
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(_isOpening ? 'ストアを開いています…' : 'アップデートする'))),
                if (!_isRequired) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(onPressed: _dismiss, child: const Text('あとで')),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error)),
                ],
              ]),
            ),
          ))),
        )),
      ]),
    );
  }
}
