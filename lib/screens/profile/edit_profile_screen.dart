import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../core/mock/api.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/fv_avatar.dart';
import '../../widgets/ui.dart';
import '../../widgets/fv_notification.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();
  bool _saving = false;
  String? _previewDataUri;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = ref.read(currentUserProvider);
    _nameController.text = u?.fullName ?? '';
    _emailController.text = u?.email ?? '';
    _previewDataUri = u?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final s = AppLocalizations.of(context);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final processed = _process(bytes, s);
      if (processed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.photoPickedError),
            backgroundColor: FvColors.error,
          ),
        );
        return;
      }
      setState(() {
        _previewDataUri = processed;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.photoPickedError),
          backgroundColor: FvColors.error,
        ),
      );
    }
  }

  /// Decodes + resizes to a max 512px JPEG so uploads stay tiny, regardless of
  /// what the platform picker hands back.
  String? _process(List<int> bytes, AppLocalizations s) {
    if (bytes.isEmpty) return null;
    if (bytes.length > 5 * 1024 * 1024) return null;
    final decoded = img.decodeImage(Uint8List.fromList(bytes));
    if (decoded == null) return null;
    const maxDim = 512.0;
    final scale = math.min(
      1.0,
      maxDim / math.max(decoded.width, decoded.height),
    );
    final resized = img.copyResize(
      decoded,
      width: math.max(1, (decoded.width * scale).round()),
      height: math.max(1, (decoded.height * scale).round()),
      interpolation: img.Interpolation.linear,
    );
    final jpg = img.encodeJpg(resized, quality: 85);
    return 'data:image/jpeg;base64,${base64Encode(jpg)}';
  }

  Future<void> _save() async {
    final s = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = s.fullNameError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    try {
      var avatarUrl = _previewDataUri;
      final current = ref.read(currentUserProvider);
      if (avatarUrl != null && avatarUrl != current?.avatarUrl) {
        final mime = avatarUrl.startsWith('data:image/png')
            ? 'image/png'
            : (avatarUrl.startsWith('data:image/jpeg') ||
                      avatarUrl.startsWith('data:image/jpg')
                  ? 'image/jpeg'
                  : 'image/jpeg');
        final comma = avatarUrl.indexOf(',');
        avatarUrl = await ref
            .read(apiProvider)
            .uploadAvatar(
              token,
              mimeType: mime,
              data: comma > -1 ? avatarUrl.substring(comma + 1) : avatarUrl,
            );
      }
      final updated = await ref
          .read(apiProvider)
          .updateMe(token, fullName: name, avatarUrl: avatarUrl);
      ref.read(authProvider.notifier).setUser(updated);
      if (mounted) {
        Navigator.of(context).pop();
        FvNotification.show(
          context,
          message: s.profileUpdated,
          type: FvNotificationType.success,
        );
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
    final user = ref.watch(currentUserProvider);
    final avatarUrl = _previewDataUri ?? user?.avatarUrl;

    return ScreenPage(
      title: s.editProfile,
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          Container(
            padding: const EdgeInsets.all(FvSpacing.x6),
            decoration: BoxDecoration(
              color: FvColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FvColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(color: FvColors.ink, offset: Offset(3, 3), blurRadius: 0),
              ],
            ),
            child: Column(
              children: [
                FvAvatar(
                  avatarUrl: avatarUrl,
                  fullName: _nameController.text.trim().isEmpty
                      ? (user?.fullName ?? '')
                      : _nameController.text.trim(),
                  radius: 44,
                  onTap: _pickImage,
                  showEditBadge: true,
                ),
                const SizedBox(height: FvSpacing.x4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FvButton(
                      label: s.uploadPhoto,
                      variant: FvButtonVariant.primary,
                      expanded: false,
                      icon: Icons.photo_library_outlined,
                      onPressed: _pickImage,
                    ),
                    if (_previewDataUri != null) ...[
                      const SizedBox(width: FvSpacing.x3),
                      TextButton.icon(
                        onPressed: () => setState(() => _previewDataUri = null),
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: context.fvError,
                        ),
                        label: Text(
                          s.removePhoto,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.fvError,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          Container(
            padding: const EdgeInsets.all(FvSpacing.x4),
            decoration: BoxDecoration(
              color: FvColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FvColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(color: FvColors.ink, offset: Offset(3, 3), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.personalInfo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: FvColors.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: FvSpacing.x4),
                _BrutalistTextField(
                  label: s.fullName,
                  controller: _nameController,
                  hint: 'Amina Diallo',
                  errorText: _error == s.fullNameError ? _error : null,
                ),
                const SizedBox(height: FvSpacing.x4),
                _BrutalistTextField(
                  label: s.email,
                  controller: _emailController,
                  enabled: false,
                  hint: user?.email ?? '',
                ),
              ],
            ),
          ),
          const SizedBox(height: FvSpacing.x5),
          if (_error != null && _error != s.fullNameError)
            Container(
              margin: const EdgeInsets.only(bottom: FvSpacing.x4),
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
          FvButton(
            label: s.save,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}


class _BrutalistTextField extends StatelessWidget {
  const _BrutalistTextField({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.hint,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hint;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: FvColors.ink,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: FvColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            errorText: errorText,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FvColors.ink, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FvColors.ink, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FvColors.ink, width: 2.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FvColors.ink, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
