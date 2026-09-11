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

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  bool _saving = false;
  String? _previewDataUri;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController.text = ref.read(currentUserProvider)?.fullName ?? '';
    _previewDataUri = ref.read(currentUserProvider)?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.profileUpdated)));
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
          FvCard(
            padding: const EdgeInsets.all(FvSpacing.x6),
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
                      variant: FvButtonVariant.secondary,
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
          FvCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.personalInfo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.fvText,
                  ),
                ),
                const SizedBox(height: FvSpacing.x4),
                FvTextField(
                  label: s.fullName,
                  controller: _nameController,
                  hint: 'Amina Diallo',
                  errorText: _error == s.fullNameError ? _error : null,
                ),
                const SizedBox(height: FvSpacing.x4),
                FvTextField(
                  label: s.email,
                  controller: TextEditingController(text: user?.email ?? ''),
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
