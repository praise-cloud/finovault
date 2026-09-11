import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class StatementUploadScreen extends ConsumerStatefulWidget {
  const StatementUploadScreen({super.key});

  @override
  ConsumerState<StatementUploadScreen> createState() =>
      _StatementUploadScreenState();
}

class _StatementUploadScreenState extends ConsumerState<StatementUploadScreen> {
  String? _sourceId;
  String? _fileName;
  String? _fileType;
  Uint8List? _fileBytes;
  bool _uploading = false;
  StatementUploadResult? _result;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    setState(() {
      _fileName = f.name;
      _fileType = (f.extension ?? 'csv').toLowerCase();
      _fileBytes = f.bytes;
    });
  }

  Future<void> _upload() async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    setState(() => _uploading = true);
    try {
      final result = await api.uploadStatement(
        token,
        accountId: _sourceId!,
        fileName: _fileName!,
        fileType: _fileType!,
        data: base64Encode(_fileBytes!),
      );
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsProvider);
      if (!mounted) return;
      setState(() => _result = result);
    } on FvApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);

    return ScreenPage(
      title: 'Upload statement',
      child: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) {
          final result = _result;
          if (result != null) return _ResultView(result: result);
          if (list.isEmpty) {
            return const Center(
              child: EmptyState(
                title: 'No accounts linked',
                body: 'Link an account before uploading a statement.',
              ),
            );
          }
          _sourceId ??= list.first.id;
          return ListView(
            padding: const EdgeInsets.all(FvSpacing.x5),
            children: [
              FvCard(
                margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import to',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _sourceId,
                      isExpanded: true,
                      items: list
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                a.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _sourceId = v),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FvRadius.input),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: FvSpacing.x4,
                          vertical: FvSpacing.x3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FvButton(
                label: _fileName ?? 'Choose file',
                icon: Icons.upload_file,
                variant: FvButtonVariant.secondary,
                onPressed: _pickFile,
              ),
              const SizedBox(height: FvSpacing.x2),
              Text(
                'CSV or PDF statement from your bank or mobile-money provider.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: context.fvTextSecondary,
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              FvButton(
                label: 'Upload',
                loading: _uploading,
                onPressed: _fileBytes == null || _uploading ? null : _upload,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final StatementUploadResult result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.fvWash,
              child: Icon(Icons.check, color: context.fvSuccess, size: 28),
            ),
            const SizedBox(height: FvSpacing.x3),
            const Text(
              'Statement imported',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: FvSpacing.x2),
            Text(
              '${result.count} transactions added',
              style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
            ),
          ],
        ),
        if (result.categories.isNotEmpty) ...[
          const SizedBox(height: FvSpacing.x4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.categories
                .map(
                  (c) => Chip(label: Text(c), backgroundColor: context.fvWash),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: FvSpacing.x5),
        FvButton(
          label: 'Done',
          variant: FvButtonVariant.success,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
