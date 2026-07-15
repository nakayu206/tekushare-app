import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// パスワードリセットページ
class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSend() {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアドレスを入力してください')),
      );
      return;
    }
    ref.read(passwordResetProvider.notifier).send(email);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final isLoading = state is PasswordResetLoading;
    final isSuccess = state is PasswordResetSuccess;
    final error = state is PasswordResetError ? state.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.passwordResetPageTitle),
        centerTitle: true,
        elevation: 0,
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
                AppStrings.passwordResetDescription,
                style: AppTextStyle.bodyMedium
                    .copyWith(color: AppColors.textDisabled),
              ),
              const SizedBox(height: AppSpacing.x4l),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isSuccess,
                decoration: InputDecoration(
                  labelText: AppStrings.passwordResetEmailLabel,
                  hintText: 'example@mail.com',
                  errorText: error,
                  errorMaxLines: 3,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSend(),
              ),
              const SizedBox(height: AppSpacing.x3l),
              if (isSuccess)
                Text(
                  AppStrings.passwordResetSuccessMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMedium
                      .copyWith(color: AppColors.primary),
                )
              else
                SizedBox(
                  height: AppSize.buttonHeight,
                  child: FilledButton(
                    onPressed: isLoading ? null : _onSend,
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
                        : const Text(AppStrings.passwordResetSendButton),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
