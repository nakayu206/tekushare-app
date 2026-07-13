import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/domain/entities/contact.dart';
import 'package:tekushare/screens/providers/contact_provider.dart';
import 'package:tekushare/screens/widgets/common/app_confirm_dialog.dart';

class PhoneRegisterPage extends ConsumerStatefulWidget {
  const PhoneRegisterPage({super.key});

  @override
  ConsumerState<PhoneRegisterPage> createState() => _PhoneRegisterPageState();
}

class _PhoneRegisterPageState extends ConsumerState<PhoneRegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AppConfirmDialog(
        message: AppStrings.settingsPhoneConfirmMessage,
        confirmLabel: AppStrings.settingsPhoneRegisterConfirm,
        onConfirm: () async {
          await ref.read(contactNotifierProvider.notifier).save(
                Contact(
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                ),
              );
          if (!mounted) return;
          Navigator.pop(context);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.settingsPhoneRegisteredMessage),
            ),
          );
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _onDelete() {
    showDialog<void>(
      context: context,
      builder: (_) => AppConfirmDialog(
        message: AppStrings.settingsPhoneDeleteConfirmMessage,
        confirmLabel: AppStrings.settingsPhoneDeleteConfirmButton,
        isDestructive: true,
        onConfirm: () async {
          await ref.read(contactNotifierProvider.notifier).delete();
          if (!mounted) return;
          Navigator.pop(context);
          if (!mounted) return;
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactAsync = ref.watch(contactProvider);

    return contactAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('エラーが発生しました')),
      ),
      data: (contact) {
        if (_nameController.text.isEmpty && contact != null) {
          _nameController.text = contact.name;
          _phoneController.text = contact.phone;
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(AppStrings.settingsInactivityContact),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      AppStrings.settingsPhoneNameLabel,
                      style: TextStyle(
                        fontSize: AppTextStyle.sm2,
                        color: AppColors.textPrimary,
                        fontWeight: AppTextStyle.medium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        AppStrings.settingsPhoneNameHint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppStrings.settingsPhoneNameRequired
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      AppStrings.settingsPhoneNumberLabel,
                      style: TextStyle(
                        fontSize: AppTextStyle.sm2,
                        color: AppColors.textPrimary,
                        fontWeight: AppTextStyle.medium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onSave(),
                      decoration: _inputDecoration(
                        AppStrings.settingsPhoneNumberHint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppStrings.settingsPhoneNumberRequired
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.x3l),
                    SizedBox(
                      width: double.infinity,
                      height: AppSize.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: Text(
                          contact == null
                              ? AppStrings.settingsPhoneRegisterConfirm
                              : AppStrings.settingsPhoneSaveButton,
                          style: const TextStyle(
                            fontSize: AppTextStyle.lg2,
                            fontWeight: AppTextStyle.medium,
                          ),
                        ),
                      ),
                    ),
                    if (contact != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: AppSize.buttonHeight,
                        child: OutlinedButton(
                          onPressed: _onDelete,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                          child: const Text(
                            AppStrings.settingsPhoneDeleteButton,
                            style: TextStyle(
                              fontSize: AppTextStyle.lg2,
                              fontWeight: AppTextStyle.medium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textDisabled,
        fontSize: AppTextStyle.md2,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.chipUnselected),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
