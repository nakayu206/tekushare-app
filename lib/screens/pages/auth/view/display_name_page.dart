import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// 表示名設定画面（初回サインイン時のみ表示）
class DisplayNamePage extends ConsumerStatefulWidget {
  const DisplayNamePage({super.key});

  @override
  ConsumerState<DisplayNamePage> createState() => _DisplayNamePageState();
}

class _DisplayNamePageState extends ConsumerState<DisplayNamePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(displayNameProvider);
    final isLoading = asyncState is AsyncLoading;

    ref.listen<AsyncValue<void>>(displayNameProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.displayNameError}: ${next.error}'),
          ),
        );
      }
      // 成功時は authStateProvider（userChanges）が自動的にホーム画面へ遷移させる
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: AppSize.appBarHeightTall,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontSize: AppTextStyle.xl,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontSize: AppTextStyle.xs2,
                color: Colors.white,
              ),
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
              const Text(AppStrings.displayNameTitle,
                  style: AppTextStyle.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.displayNameSubtitle,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: AppSpacing.x4l),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: AppStrings.nicknameLabel,
                  hintText: AppStrings.nicknameHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
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
                          AppStrings.displayNameSubmit,
                          style: AppTextStyle.titleMedium.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.nicknameRequired)),
      );
      return;
    }
    ref.read(displayNameProvider.notifier).save(name);
  }
}
