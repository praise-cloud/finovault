import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/mock/api.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = AppLocalizations.of(context);
    final current = _currentController.text;
    final next = _newController.text;
    if (next.length < 8) {
      setState(() => _error = s.passwordTooShort);
      return;
    }
    if (next != _confirmController.text) {
      setState(() => _error = s.passwordsDontMatch);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    try {
      await ref
          .read(apiProvider)
          .changePassword(token, currentPassword: current, newPassword: next);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.passwordChanged)));
      }
    } on FvApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = s.connectionFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final strength = FvFormat.passwordStrength(_newController.text);
    const strengthLabels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];

    return ScreenPage(
      title: s.changePassword,
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          FvCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FvTextField(
                  label: s.currentPassword,
                  controller: _currentController,
                  obscure: true,
                ),
                const SizedBox(height: FvSpacing.x4),
                FvTextField(
                  label: s.newPassword,
                  controller: _newController,
                  obscure: true,
                ),
                if (_newController.text.isNotEmpty) ...[
                  const SizedBox(height: FvSpacing.x2),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: strength / 4,
                            minHeight: 4,
                            backgroundColor: context.fvBorder,
                            color: strength >= 3
                                ? context.fvSuccess
                                : (strength == 2
                                      ? context.fvWarning
                                      : context.fvError),
                          ),
                        ),
                      ),
                      const SizedBox(width: FvSpacing.x2),
                      Text(
                        strengthLabels[strength],
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: context.fvTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: FvSpacing.x4),
                FvTextField(
                  label: s.confirmNewPassword,
                  controller: _confirmController,
                  obscure: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: FvSpacing.x3),
                  Container(
                    padding: const EdgeInsets.all(FvSpacing.x3),
                    decoration: BoxDecoration(
                      color: FvColors.errorBg,
                      borderRadius: BorderRadius.circular(FvRadius.input),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(fontSize: 13, color: context.fvError),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: FvSpacing.x5),
          FvButton(
            label: s.save,
            loading: _saving,
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
