import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';


class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(securityOverviewProvider);
    final devices = ref.watch(securityDevicesProvider);
    final events = ref.watch(securityEventsProvider);

    return ScreenPage(
      title: 'Security',
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          overview.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (o) => FvCard(
              margin: const EdgeInsets.only(bottom: FvSpacing.x4),
              child: Row(
                children: [
                  ProgressRing(progress: (o.score / 99).clamp(0.0, 1.0), size: 72, stroke: 8),
                  const SizedBox(width: FvSpacing.x4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Security score', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.fvText)),
                        const SizedBox(height: 2),
                        Text('$o.score / 99', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                        const SizedBox(height: FvSpacing.x2),
                        Row(
                          children: [
                            Text('Two-factor', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                            Switch(
                              value: o.twoFactorEnabled,
                              activeThumbColor: FvColors.primary,
                              onChanged: (v) async {
                                final api = ref.read(apiProvider);
                                final token = ref.read(kvStoreProvider).getString(sessionKey);
                                await api.setTwoFactor(token, enabled: v);
                                ref.invalidate(securityOverviewProvider);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Devices'),
          devices.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Column(
              children: [
                for (final d in list)
                  FvCard(
                    margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                    child: Row(
                      children: [
                        const Icon(Icons.devices_outlined, size: 20, color: FvColors.primary),
                        const SizedBox(width: FvSpacing.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                              const SizedBox(height: 2),
                              Text('Last seen ${FvFormat.formatRelativeTime(d.lastSeen)}', style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                            ],
                          ),
                        ),
                        if (d.trusted) const StatusBadge(label: 'Trusted', foreground: FvColors.primary, background: FvColors.wash),
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
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => list.isEmpty
                ? const EmptyState(title: 'No security events', body: 'We will flag anything unusual here.')
                : Column(
                    children: [
                      for (final e in list)
                        FvCard(
                          margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: e.severity == EventSeverity.high ? FvColors.error : FvColors.warning, shape: BoxShape.circle)),
                              const SizedBox(width: FvSpacing.x3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                                    if (e.description != null) ...[
                                      const SizedBox(height: 2),
                                      Text(e.description!, style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                                    ],
                                  ],
                                ),
                              ),
                              if (!e.resolved)
                                TextButton(
                                  onPressed: () async {
                                    final api = ref.read(apiProvider);
                                    final token = ref.read(kvStoreProvider).getString(sessionKey);
                                    await api.resolveSecurityEvent(token, e.id);
                                    ref.invalidate(securityEventsProvider);
                                  },
                                  child: const Text('Resolve', style: TextStyle(color: FvColors.primary, fontWeight: FontWeight.w600)),
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
}


