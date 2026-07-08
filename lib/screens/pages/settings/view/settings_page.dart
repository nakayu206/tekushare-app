import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';
import 'package:tekushare/screens/pages/settings/viewmodel/settings_viewmodel.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

/// 設定画面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  void _showPhoneSelectDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _PhoneSelectDialog(
        onSelect: (contact) {
          Navigator.pop(context);
          if (!mounted) return;
          _showPhoneConfirmDialog(contact);
        },
      ),
    );
  }

  void _showPhoneConfirmDialog(PhoneContact contact) {
    final vm = ref.read(settingsViewModelProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => _PhoneConfirmDialog(
        contact: contact,
        onConfirm: () {
          vm.registerContact(contact.name);
          Navigator.pop(context);
          if (!mounted) return;
          _showRegisteredDialog();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showRegisteredDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _RegisteredDialog(
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmActionDialog(
        message: AppStrings.settingsLogoutConfirmMessage,
        confirmLabel: AppStrings.settingsLogoutConfirmButton,
        isDestructive: false,
        onConfirm: () {
          ref.read(walkSessionProvider.notifier).resetWalk();
          ref.read(authServiceProvider).signOut();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showDeleteAccountConfirmDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmActionDialog(
        message: AppStrings.settingsDeleteAccountConfirmMessage,
        confirmLabel: AppStrings.settingsDeleteAccountConfirmButton,
        isDestructive: true,
        onConfirm: () {
          ref.read(walkSessionProvider.notifier).resetWalk();
          ref.read(authServiceProvider).deleteUser();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.settingsTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              _TimerCard(state: state, vm: vm),
              const SizedBox(height: AppSpacing.x2lp),
              _InactivityCard(
                state: state,
                vm: vm,
                onContactTap: _showPhoneSelectDialog,
              ),
              const SizedBox(height: AppSpacing.x2lp),
              _ShareCard(state: state, vm: vm),
              const SizedBox(height: AppSpacing.x2lp),
              _AccountCard(
                onLogout: _showLogoutConfirmDialog,
                onDeleteAccount: _showDeleteAccountConfirmDialog,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpotListPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalkRoutePage()),
            );
          }
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// カード共通コンテナ
// ──────────────────────────────────────────

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppSpacing.sm,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────
// 片道/往復 セグメントボタン
// ──────────────────────────────────────────

class _SegmentButtons extends StatelessWidget {
  const _SegmentButtons({required this.roundTrip, required this.onToggle});

  final bool roundTrip;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SegmentBtn(
          label: AppStrings.oneWay,
          isSelected: !roundTrip,
          onTap: () => onToggle(false),
        ),
        _SegmentBtn(
          label: AppStrings.settingsTimerRoundTrip,
          isSelected: roundTrip,
          onTap: () => onToggle(true),
        ),
      ],
    );
  }
}

class _SegmentBtn extends StatelessWidget {
  const _SegmentBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizing.segmentBtnWidth,
        height: AppSize.segmentBtnH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xxs),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: AppSpacing.xs,
                    offset: const Offset(0, AppSpacing.xs),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTextStyle.md,
            color: isSelected ? AppColors.primary : AppColors.textDisabled,
            fontWeight: isSelected ? AppTextStyle.medium : AppTextStyle.regular,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 時間ドロップダウン
// ──────────────────────────────────────────

class _MinutePicker extends StatefulWidget {
  const _MinutePicker({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  State<_MinutePicker> createState() => _MinutePickerState();
}

class _MinutePickerState extends State<_MinutePicker> {
  void _showPicker() {
    final initialIndex = widget.options
        .indexOf(widget.value)
        .clamp(0, widget.options.length - 1);
    final controller = FixedExtentScrollController(initialItem: initialIndex);
    var selected = widget.value;

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: AppSize.pickerSheetH,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    widget.onChanged(selected);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    AppStrings.pickerDone,
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: controller,
                  itemExtent: AppSize.pickerItemH,
                  onSelectedItemChanged: (index) {
                    selected = widget.options[index];
                  },
                  children: widget.options
                      .map(
                        (m) => Center(
                          child: Text(
                            '$m${AppStrings.minuteSuffix}',
                            style: const TextStyle(fontSize: AppTextStyle.lg),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.value}${AppStrings.minuteSuffix}',
            style: const TextStyle(
              fontSize: AppTextStyle.md2,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: AppSize.pickerGap),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(1.0, 1.5, 1.0),
            child: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
              size: AppSize.iconXl,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// タイマーカード
// ──────────────────────────────────────────

class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.state, required this.vm});

  final SettingsState state;
  final SettingsViewModel vm;

  static final _timerOptions = List.generate(24, (i) => (i + 1) * 5);

  @override
  Widget build(BuildContext context) {
    return _SettingCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.timerCardPaddingH,
        vertical: AppSize.timerCardPaddingV,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/SVG/hourglass.svg',
                  width: AppSize.iconXs,
                  height: AppSize.iconMd,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.settingsTimerTitle,
                      style: TextStyle(
                        fontSize: AppTextStyle.lg2,
                        fontWeight: AppTextStyle.semiBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      AppStrings.settingsTimerSubtitle,
                      style: TextStyle(
                        fontSize: AppTextStyle.xxs,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              _SegmentButtons(
                roundTrip: state.timerRoundTrip,
                onToggle: vm.setTimerRoundTrip,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _CustomSwitch(
                value: state.timerEnabled,
                onChanged: vm.setTimerEnabled,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                state.timerEnabled ? AppStrings.switchOn : AppStrings.switchOff,
                style: TextStyle(
                  fontSize: AppTextStyle.md2,
                  fontWeight: AppTextStyle.bold,
                  color: state.timerEnabled
                      ? AppColors.primary
                      : AppColors.textDisabled,
                ),
              ),
              const Spacer(),
              _MinutePicker(
                value: state.timerMinutes,
                options: _timerOptions,
                onChanged: vm.setTimerMinutes,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 安否確認カード
// ──────────────────────────────────────────

class _InactivityCard extends StatelessWidget {
  const _InactivityCard({
    required this.state,
    required this.vm,
    required this.onContactTap,
  });

  final SettingsState state;
  final SettingsViewModel vm;
  final VoidCallback onContactTap;

  static final _inactivityOptions = List.generate(24, (i) => (i + 1) * 5);

  @override
  Widget build(BuildContext context) {
    return _SettingCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.timerCardPaddingH,
        vertical: AppSize.timerCardPaddingV,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/SVG/heart.svg',
                  width: AppSize.iconXs,
                  height: AppSize.iconMd,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.settingsInactivityTitle,
                      style: TextStyle(
                        fontSize: AppTextStyle.lg2,
                        fontWeight: AppTextStyle.semiBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      AppStrings.settingsInactivitySubtitle,
                      style: TextStyle(
                        fontSize: AppTextStyle.xs,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onContactTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: SvgPicture.asset(
                        'assets/SVG/phone.svg',
                        width: AppSize.iconLg,
                        height: AppSize.iconLg,
                      ),
                    ),
                    const SizedBox(width: AppSize.phoneIconGap),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.settingsInactivityContact,
                          style: TextStyle(
                            fontSize: AppTextStyle.xs,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          AppStrings.settingsInactivityContactSet,
                          style: TextStyle(
                            fontSize: AppTextStyle.sm2,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _CustomSwitch(
                value: state.inactivityEnabled,
                onChanged: vm.setInactivityEnabled,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                state.inactivityEnabled
                    ? AppStrings.switchOn
                    : AppStrings.switchOff,
                style: TextStyle(
                  fontSize: AppTextStyle.md2,
                  fontWeight: AppTextStyle.bold,
                  color: state.inactivityEnabled
                      ? AppColors.primary
                      : AppColors.textDisabled,
                ),
              ),
              const Spacer(),
              _MinutePicker(
                value: state.inactivityMinutes,
                options: _inactivityOptions,
                onChanged: vm.setInactivityMinutes,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// シェアカード
// ──────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.state, required this.vm});

  final SettingsState state;
  final SettingsViewModel vm;

  static const _shareLink = 'https://tekushare.app/share/abc...';

  @override
  Widget build(BuildContext context) {
    return _SettingCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.timerCardPaddingH,
        vertical: AppSize.timerCardPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/SVG/arrow.svg',
                  width: AppSize.iconXs,
                  height: AppSize.iconMd,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.settingsShareTitle,
                    style: TextStyle(
                      fontSize: AppTextStyle.lg2,
                      fontWeight: AppTextStyle.semiBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    AppStrings.settingsShareSubtitle,
                    style: TextStyle(
                      fontSize: AppTextStyle.xs,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final name in state.sharedAccounts)
            Dismissible(
              key: ValueKey(name),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => showDialog<bool>(
                context: context,
                builder: (_) => _SharedAccountDeleteDialog(
                  name: name,
                  onConfirm: () => Navigator.pop(context, true),
                  onCancel: () => Navigator.pop(context, false),
                ),
              ).then((v) => v ?? false),
              onDismissed: (_) => vm.removeSharedAccount(name),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: const Text(
                  AppStrings.settingsShareDeleteAccount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTextStyle.sm2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _ContactRow(
                    name: name,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _SharedRoutesPage(accountName: name),
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          const SizedBox(height: AppSpacing.x4lp),
          const _ShareLinkArea(link: _shareLink),
          const SizedBox(height: AppSpacing.x2lm),
          const Center(
            child: Text(
              AppStrings.settingsShareViaApp,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppTextStyle.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2lmm),
          const _ShareAppIcons(),
          const SizedBox(height: AppSpacing.x3lp),
          const Center(
            child: Text(
              AppStrings.settingsShareContent,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppTextStyle.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lgp),
          _ShareCheckbox(
            label: AppStrings.settingsShareWantToGo,
            value: state.shareWantToGo,
            onChanged: (v) => vm.setShareWantToGo(v ?? false),
          ),
          _ShareCheckbox(
            label: AppStrings.settingsShareVisited,
            value: state.shareVisited,
            onChanged: (v) => vm.setShareVisited(v ?? false),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: AppSize.buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.saved)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              child: const Text(
                AppStrings.settingsShareSaveButton,
                style: TextStyle(
                  fontSize: AppTextStyle.lg2,
                  fontWeight: AppTextStyle.medium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: AppTextStyle.sm2,
                  color: Colors.black,
                ),
              ),
            ),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'スポットを見る',
                  style: TextStyle(
                    fontSize: AppTextStyle.xs,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: AppSize.iconMd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedRoutesPage extends StatelessWidget {
  const _SharedRoutesPage({required this.accountName});

  final String accountName;

  static const _mockSpots = [
    (name: 'お気に入り公園', category: '公園', status: '行きたい！'),
    (name: '駅前カフェ', category: 'カフェ', status: '行った！'),
    (name: '商店街の和食屋', category: 'ランチ', status: '行きたい！'),
    (name: '図書館前の広場', category: 'そのほか', status: '行った！'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(accountName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: _mockSpots.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final spot = _mockSpots[i];
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.chipUnselected),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: AppSpacing.xs,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: AppTextStyle.md2,
                            fontWeight: AppTextStyle.medium,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          spot.category,
                          style: const TextStyle(
                            fontSize: AppTextStyle.sm,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      spot.status,
                      style: const TextStyle(
                        fontSize: AppTextStyle.xs,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShareLinkArea extends StatelessWidget {
  const _ShareLinkArea({required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.shareLinkBg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.settingsShareLinkLabel,
                  style: TextStyle(
                    fontSize: AppTextStyle.xs,
                    color: AppColors.shareLinkLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  link,
                  style: const TextStyle(
                    fontSize: AppTextStyle.sm,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: link)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.shareLinkButton,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            child: const Text(
              AppStrings.settingsShareLinkCopy,
              style: TextStyle(fontSize: AppTextStyle.sm),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareAppIcons extends StatelessWidget {
  const _ShareAppIcons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _AppIconItem(
          assetPath: 'assets/SVG/LINE.png',
          isPng: true,
          label: 'LINE',
          onTap: () {},
        ),
        _AppIconItem(
          assetPath: 'assets/SVG/Instagram.png',
          isPng: true,
          label: 'Instagram',
          onTap: () {},
        ),
        _AppIconItem(
          assetPath: 'assets/SVG/X.png',
          isPng: true,
          label: 'X',
          onTap: () {},
        ),
      ],
    );
  }
}

class _AppIconItem extends StatelessWidget {
  const _AppIconItem({
    required this.assetPath,
    required this.isPng,
    required this.label,
    required this.onTap,
  });

  final String assetPath;
  final bool isPng;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(
              assetPath,
              width: AppSize.iconLgp,
              height: AppSize.iconLgp,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTextStyle.xs,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCheckbox extends StatelessWidget {
  const _ShareCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: AppTextStyle.md2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          side: const BorderSide(color: AppColors.textDisabled),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 電話番号選択ダイアログ
// ──────────────────────────────────────────

class _PhoneSelectDialog extends StatelessWidget {
  const _PhoneSelectDialog({required this.onSelect});

  final ValueChanged<PhoneContact> onSelect;

  static const _contacts = <PhoneContact>[
    (name: 'あかり（娘）', phone: '080-XXXX-XXXX'),
    (name: 'いきいき介護...', phone: '080-XXXX-XXXX'),
    (name: 'たかし（弟）', phone: '080-XXXX-XXXX'),
    (name: '坂本病院', phone: '080-XXXX-XXXX'),
    (name: '警察', phone: '110'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.settingsPhoneSelectTitle,
              style: TextStyle(
                fontSize: AppTextStyle.lg2,
                fontWeight: AppTextStyle.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._contacts.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: AppTextStyle.md2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            c.phone,
                            style: const TextStyle(
                              fontSize: AppTextStyle.sm,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: AppSize.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => onSelect(c),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: const Text(
                          AppStrings.settingsPhoneRegisterButton,
                          style: TextStyle(fontSize: AppTextStyle.xs),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 電話番号登録確認ダイアログ
// ──────────────────────────────────────────

class _PhoneConfirmDialog extends StatelessWidget {
  const _PhoneConfirmDialog({
    required this.contact,
    required this.onConfirm,
    required this.onCancel,
  });

  final PhoneContact contact;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Text(
              contact.name,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppTextStyle.lg2,
                fontWeight: AppTextStyle.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              contact.phone,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppTextStyle.md,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              AppStrings.settingsPhoneConfirmMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppTextStyle.md),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text(AppStrings.cancelButton),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text(AppStrings.settingsPhoneRegisterConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 登録完了ダイアログ
// ──────────────────────────────────────────

class _RegisteredDialog extends StatelessWidget {
  const _RegisteredDialog({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              AppStrings.settingsPhoneRegisteredMessage,
              style: TextStyle(
                fontSize: AppTextStyle.lg2,
                fontWeight: AppTextStyle.medium,
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            SizedBox(
              width: double.infinity,
              height: AppSize.buttonHeight,
              child: ElevatedButton(
                onPressed: onClose,
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
    );
  }
}

// ──────────────────────────────────────────
// 共有アカウント消去確認ダイアログ
// ──────────────────────────────────────────

class _SharedAccountDeleteDialog extends StatelessWidget {
  const _SharedAccountDeleteDialog({
    required this.name,
    required this.onConfirm,
    required this.onCancel,
  });

  final String name;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Text(
              name,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppTextStyle.lg2,
                fontWeight: AppTextStyle.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              AppStrings.settingsShareDeleteConfirmMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppTextStyle.md),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text(AppStrings.cancelButton),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child:
                        const Text(AppStrings.settingsShareDeleteConfirmButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// アカウントカード
// ──────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.onLogout,
    required this.onDeleteAccount,
  });

  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return _SettingCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.timerCardPaddingH,
        vertical: AppSize.timerCardPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.settingsAccountTitle,
            style: TextStyle(
              fontSize: AppTextStyle.lg2,
              fontWeight: AppTextStyle.semiBold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: AppSize.buttonHeight,
            child: OutlinedButton(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              child: const Text(
                AppStrings.settingsLogout,
                style: TextStyle(
                  fontSize: AppTextStyle.lg2,
                  fontWeight: AppTextStyle.medium,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: AppSize.buttonHeight,
            child: ElevatedButton(
              onPressed: onDeleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              child: const Text(
                AppStrings.settingsDeleteAccount,
                style: TextStyle(
                  fontSize: AppTextStyle.lg2,
                  fontWeight: AppTextStyle.medium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 汎用確認ダイアログ（ログアウト・アカウント消去）
// ──────────────────────────────────────────

class _ConfirmActionDialog extends StatelessWidget {
  const _ConfirmActionDialog({
    required this.message,
    required this.confirmLabel,
    required this.isDestructive,
    required this.onConfirm,
    required this.onCancel,
  });

  final String message;
  final String confirmLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: AppTextStyle.sm2),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text(AppStrings.cancelButton),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      backgroundColor:
                          isDestructive ? Colors.red : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// カスタムスイッチ
// ──────────────────────────────────────────

class _CustomSwitch extends StatelessWidget {
  const _CustomSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: AppSize.switchTrackW,
          height: AppSize.switchTrackH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            color: value ? AppColors.primary : AppColors.textDisabled,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: (AppSize.switchTrackH - AppSize.switchThumb) / 2,
              ),
              child: Container(
                width: AppSize.switchThumb,
                height: AppSize.switchThumb,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
