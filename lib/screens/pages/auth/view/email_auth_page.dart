import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/auth/view/password_reset_page.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// メールアドレス認証画面（ログイン / 新規登録）
class EmailAuthPage extends ConsumerStatefulWidget {
  const EmailAuthPage({super.key});

  @override
  ConsumerState<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends ConsumerState<EmailAuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(emailAuthProvider);
    final isLoading = authState is EmailAuthLoading;
    final error = authState is EmailAuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 72,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              AppStrings.appTagline,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
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
              Text(
                _isRegisterMode ? '新規登録' : 'ログイン',
                style: AppTextStyle.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isRegisterMode
                    ? 'メールアドレスを入力してください。\nパスワード設定用のリンクをメールでお送りします。'
                    : 'メールアドレスとパスワードを入力してください',
                style: AppTextStyle.bodyMedium
                    .copyWith(color: AppColors.textDisabled),
              ),
              const SizedBox(height: AppSpacing.x4l),
              if (_isRegisterMode) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ニックネーム',
                    hintText: '例：やまだたろう',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  hintText: 'example@mail.com',
                  errorText: error,
                  errorMaxLines: 3,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
                textInputAction: _isRegisterMode
                    ? TextInputAction.done
                    : TextInputAction.next,
                onSubmitted: _isRegisterMode ? (_) => _submit() : null,
              ),
              if (!_isRegisterMode) ...[
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    hintText: '6文字以上',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ],
              const SizedBox(height: AppSpacing.x3l),
              SizedBox(
                height: AppSize.buttonHeight,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: AppSize.iconMd,
                          height: AppSize.iconMd,
                          child: CircularProgressIndicator(
                            strokeWidth: AppSize.borderThick,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Text(
                          _isRegisterMode ? '登録する' : 'ログイン',
                          style: AppTextStyle.titleMedium
                              .copyWith(color: AppColors.textOnPrimary),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              TextButton(
                onPressed: isLoading ? null : _toggleMode,
                child: Text(
                  _isRegisterMode ? 'すでにアカウントをお持ちの方はこちら' : 'アカウントをお持ちでない方はこちら',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              if (!_isRegisterMode)
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PasswordResetPage(),
                            ),
                          ),
                  child: const Text(
                    AppStrings.passwordResetLinkLabel,
                    style: TextStyle(color: AppColors.textDisabled),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleMode() {
    ref.read(emailAuthProvider.notifier).reset();
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    if (_isRegisterMode) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _showSnack('ニックネームを入力してください');
        return;
      }
      if (email.isEmpty) {
        _showSnack('メールアドレスを入力してください');
        return;
      }
      if (!_isValidEmail(email)) {
        _showSnack('メールアドレスの形式が正しくありません');
        return;
      }
      ref.read(emailAuthProvider.notifier).register(email, name);
    } else {
      final password = _passwordController.text;
      if (email.isEmpty) {
        _showSnack('メールアドレスを入力してください');
        return;
      }
      if (!_isValidEmail(email)) {
        _showSnack('メールアドレスの形式が正しくありません');
        return;
      }
      if (password.isEmpty) {
        _showSnack('パスワードを入力してください');
        return;
      }
      if (password.length < 6) {
        _showSnack('パスワードは6文字以上で入力してください');
        return;
      }
      ref.read(emailAuthProvider.notifier).signIn(email, password);
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
