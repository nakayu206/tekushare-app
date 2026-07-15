import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/domain/repositories/account_link_repository.dart';
import 'package:tekushare/screens/providers/account_link_provider.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

/// 招待リンクを開いた側に表示する連携承認画面
class AcceptInvitePage extends ConsumerStatefulWidget {
  const AcceptInvitePage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<AcceptInvitePage> createState() => _AcceptInvitePageState();
}

class _AcceptInvitePageState extends ConsumerState<AcceptInvitePage> {
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await ref.read(accountLinkRepositoryProvider).acceptInvite(widget.token);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4l,
            vertical: AppSpacing.x2l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2l,
              AppSpacing.x3l,
              AppSpacing.x2l,
              AppSpacing.x2l,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.acceptInviteSuccessMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppTextStyle.lg2,
                    fontWeight: AppTextStyle.semiBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.x2l),
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.x5l,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text(AppStrings.closeButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e, st) {
      debugPrint('acceptInvite error: $e\n$st');
      if (!mounted) return;
      setState(() => _accepting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(e))),
      );
    }
  }

  String _errorMessage(Object e) {
    if (e is InviteInvalidException) {
      return AppStrings.acceptInviteInvalidMessage;
    }
    if (e is SelfInviteException) return AppStrings.acceptInviteSelfMessage;
    if (e is AlreadyLinkedException) {
      return AppStrings.acceptInviteAlreadyLinkedMessage;
    }
    return AppStrings.acceptInviteErrorMessage;
  }

  @override
  Widget build(BuildContext context) {
    final inviteAsync = ref.watch(inviteDetailsProvider(widget.token));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.acceptInviteTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: inviteAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text(
                _errorMessage(e),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: AppTextStyle.md),
              ),
              data: (invite) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${invite.fromDisplayName}${AppStrings.acceptInviteMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppTextStyle.x1l,
                      fontWeight: AppTextStyle.semiBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    AppStrings.acceptInviteDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTextStyle.sm,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  SizedBox(
                    width: double.infinity,
                    height: AppSize.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _accepting ? null : _accept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      child: _accepting
                          ? const SizedBox(
                              width: AppSize.iconSm,
                              height: AppSize.iconSm,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              AppStrings.acceptInviteConfirmButton,
                              style: TextStyle(
                                fontSize: AppTextStyle.lg2,
                                fontWeight: AppTextStyle.medium,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
