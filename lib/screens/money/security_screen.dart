import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/mock/api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../auth/otp_screen.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(securityOverviewProvider);
    final devices = ref.watch(securityDevicesProvider);
    final events = ref.watch(securityEventsProvider);

    return ScreenPage(
      title: AppLocalizations.of(context).security,
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          overview.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
            data: (o) => _buildOverview(context, ref, o),
          ),
          const SectionHeader(title: 'Devices'),
          devices.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) => Column(
              children: [
                for (final d in list)
                  FvCard(
                    margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.devices_outlined,
                          size: 20,
                          color: context.fvPrimary,
                        ),
                        const SizedBox(width: FvSpacing.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.fvText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Last seen ${FvFormat.formatRelativeTime(d.lastSeen)}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.fvTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (d.trusted)
                          StatusBadge(
                            label: 'Trusted',
                            foreground: context.fvPrimary,
                            background: context.fvWash,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          const SectionHeader(title: 'Events'),
          events.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) => list.isEmpty
                ? const EmptyState(
                    title: 'No security events',
                    body: 'We will flag anything unusual here.',
                  )
                : Column(
                    children: [
                      for (final e in list)
                        FvCard(
                          margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: e.severity == EventSeverity.high
                                      ? context.fvError
                                      : context.fvWarning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: FvSpacing.x3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.fvText,
                                      ),
                                    ),
                                    if (e.description != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        e.description!,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: context.fvTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!e.resolved)
                                TextButton(
                                  onPressed: () async {
                                    final api = ref.read(apiProvider);
                                    final token = ref
                                        .read(kvStoreProvider)
                                        .getString(sessionKey);
                                    await api.resolveSecurityEvent(token, e.id);
                                    ref.invalidate(securityEventsProvider);
                                  },
                                  child: Text(
                                    'Resolve',
                                    style: TextStyle(
                                      color: context.fvPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    WidgetRef ref,
    SecurityOverview o,
  ) {
    final s = AppLocalizations.of(context);
    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProgressRing(
                progress: (o.score / 99).clamp(0.0, 1.0),
                size: 72,
                stroke: 8,
              ),
              const SizedBox(width: FvSpacing.x4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.securityScore,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.fvText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.securityScoreOutOf(o.score),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FvSpacing.x4),
          const Divider(height: 1),
          const SizedBox(height: FvSpacing.x4),
          Row(
            children: [
              Icon(
                o.twoFactorEnabled
                    ? Icons.shield_outlined
                    : Icons.shield_outlined,
                size: 22,
                color: o.twoFactorEnabled
                    ? context.fvSuccess
                    : context.fvTextSecondary,
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Two-factor authentication',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.fvText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      o.twoFactorEnabled
                          ? s.twoFactorStatusEnabled
                          : s.twoFactorStatusDisabled,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FvSpacing.x3),
          if (o.twoFactorEnabled)
            Row(
              children: [
                Expanded(
                  child: FvButton(
                    label: s.twoFactorManage,
                    variant: FvButtonVariant.secondary,
                    onPressed: () => _showDisable2FA(context, ref),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FvButton(
                    label: s.twoFactorSetUp,
                    onPressed: () => _startSetup(context, ref),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _startSetup(BuildContext context, WidgetRef ref) async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    try {
      final setup = await api.beginTwoFactorSetup(token);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => OtpScreen(
            mode: OtpMode.setup,
            setupData: setup,
            onCompleted: () => ref.invalidate(securityOverviewProvider),
          ),
        ),
      );
    } on FvApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _showDisable2FA(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.twoFactorDisableTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.twoFactorDisableBody,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: FvSpacing.x4),
            FvTextField(
              label: s.twoFactorCodeLabel,
              controller: codeController,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (codeController.text.length > 6) {
                  codeController.text = codeController.text.substring(0, 6);
                  codeController.selection = TextSelection.collapsed(
                    offset: codeController.text.length,
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.length < 6) return;
              Navigator.of(ctx).pop();
              try {
                final api = ref.read(apiProvider);
                final token = ref.read(kvStoreProvider).getString(sessionKey);
                await api.disableTwoFactor(token, code);
                ref.invalidate(securityOverviewProvider);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s.twoFactorDisabled)));
              } on FvApiException catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
            child: Text(s.disable, style: TextStyle(color: context.fvError)),
          ),
        ],
      ),
    );
  }
}
