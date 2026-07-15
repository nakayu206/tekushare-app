import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  static const _pollInterval = Duration(seconds: 3);

  Timer? _timer;
  bool _isSending = false;
  bool _resendSuccess = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      await ref.read(authServiceProvider).reloadCurrentUser();
    } catch (_) {
      // ポーリング失敗は無視して次のタイミングで再試行
    }
  }

  Future<void> _onResend() async {
    setState(() {
      _isSending = true;
      _resendSuccess = false;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _resendSuccess = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _error = _mapErrorCode(e.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _error = AppStrings.operationError;
      });
    }
  }

  Future<void> _onLogout() async {
    await ref.read(authServiceProvider).signOut();
  }

  String _mapErrorCode(String code) {
    return switch (code) {
      'too-many-requests' => 'しばらく時間をおいてから再度お試しください',
      _ => AppStrings.operationError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.emailVerificationPageTitle),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x3l,
            vertical: AppSpacing.x4l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.x3l),
              const Text(
                AppStrings.emailVerificationSentMessage,
                textAlign: TextAlign.center,
                style: AppTextStyle.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$email${AppStrings.emailVerificationDescription}',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium
                    .copyWith(color: AppColors.textDisabled),
              ),
              const SizedBox(height: AppSpacing.x4l),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: AppSize.iconSm,
                    height: AppSize.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSize.borderThick,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppStrings.emailVerificationChecking,
                    style: AppTextStyle.captionSecondary
                        .copyWith(color: AppColors.textDisabled),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x4l),
              if (_resendSuccess)
                Text(
                  AppStrings.emailVerificationResendSuccess,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMedium
                      .copyWith(color: AppColors.primary),
                ),
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.captionSecondary
                      .copyWith(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: AppSize.buttonHeight,
                child: OutlinedButton(
                  onPressed: _isSending ? null : _onResend,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: AppSize.iconMd,
                          height: AppSize.iconMd,
                          child: CircularProgressIndicator(
                            strokeWidth: AppSize.borderThick,
                            color: AppColors.primary,
                          ),
                        )
                      : const Text(AppStrings.emailVerificationResendButton),
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              TextButton(
                onPressed: _onLogout,
                child: const Text(
                  AppStrings.settingsLogout,
                  style: TextStyle(color: AppColors.textDisabled),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
