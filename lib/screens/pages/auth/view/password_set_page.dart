import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// パスワードリセットメールのリンクから遷移するパスワード設定画面
class PasswordSetPage extends ConsumerStatefulWidget {
  const PasswordSetPage({super.key, required this.oobCode});

  final String oobCode;

  @override
  ConsumerState<PasswordSetPage> createState() => _PasswordSetPageState();
}

class _PasswordSetPageState extends ConsumerState<PasswordSetPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isVerifying = true;
  bool _isSending = false;
  String? _email;
  String? _codeError;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyCode());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    try {
      final email = await ref
          .read(authServiceProvider)
          .verifyPasswordResetCode(widget.oobCode);
      if (!mounted) return;
      setState(() {
        _email = email;
        _isVerifying = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _codeError = _mapCodeError(e.code);
        _isVerifying = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _codeError = AppStrings.operationError;
        _isVerifying = false;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      setState(() => _error = 'パスワードは6文字以上で入力してください');
      return;
    }
    if (!password.contains(RegExp(r'[a-zA-Z]')) ||
        !password.contains(RegExp(r'[0-9]'))) {
      setState(() => _error = 'パスワードは英字と数字を両方含めてください');
      return;
    }
    if (password != confirm) {
      setState(() => _error = AppStrings.passwordMismatch);
      return;
    }

    setState(() {
      _error = null;
      _isSending = true;
    });

    try {
      final service = ref.read(authServiceProvider);
      await service.confirmPasswordReset(widget.oobCode, password);
      await service.signInWithEmail(_email!, password);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _mapError(e.code);
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppStrings.operationError;
        _isSending = false;
      });
    }
  }

  String _mapCodeError(String code) {
    return switch (code) {
      'invalid-action-code' ||
      'expired-action-code' =>
        AppStrings.passwordSetInvalidCode,
      _ => AppStrings.operationError,
    };
  }

  String _mapError(String code) {
    return switch (code) {
      'weak-password' => 'パスワードは6文字以上の英数字を含めてください',
      'network-request-failed' => 'ネットワークエラーが発生しました。接続を確認してください',
      _ => AppStrings.operationError,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          AppStrings.passwordSetPageTitle,
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isVerifying
            ? const Center(child: CircularProgressIndicator())
            : _codeError != null
                ? _buildErrorBody()
                : _buildForm(),
      ),
    );
  }

  Widget _buildErrorBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.x2l),
            Text(
              _codeError!,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.x3l),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3l,
        vertical: AppSpacing.x4l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            AppStrings.passwordSetPageTitle,
            style: AppTextStyle.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.passwordSetDescription,
            style:
                AppTextStyle.bodyMedium.copyWith(color: AppColors.textDisabled),
          ),
          const SizedBox(height: AppSpacing.x4l),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: AppStrings.passwordSetLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: AppStrings.passwordSetConfirmLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _isSending ? null : _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: AppTextStyle.captionSecondary
                  .copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.x3l),
          SizedBox(
            height: AppSize.buttonHeight,
            child: FilledButton(
              onPressed: _isSending ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
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
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Text(AppStrings.passwordSetButton),
            ),
          ),
        ],
      ),
    );
  }
}
