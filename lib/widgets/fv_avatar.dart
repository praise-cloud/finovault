import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'ui.dart';

/// Renders a user's avatar from an https URL, an inline `data:` URI, or falls
/// back to a coloured initials circle. Used everywhere a profile picture
/// appears (profile tab header, edit-profile preview, etc.).
class FvAvatar extends StatelessWidget {
  const FvAvatar({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.radius = 26,
    this.onTap,
    this.showEditBadge = false,
  });

  final String? avatarUrl;
  final String fullName;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  String get _initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _fallback(BuildContext context) =>
      _InitialsCircle(initials: _initials, radius: radius);

  @override
  Widget build(BuildContext context) {
    final fallback = _fallback(context);

    Widget image;
    final url = avatarUrl ?? '';
    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma > -1) {
        try {
          final bytes = base64Decode(url.substring(comma + 1));
          image = ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (_, _, _) => fallback,
            ),
          );
        } on FormatException {
          image = fallback;
        }
      } else {
        image = fallback;
      }
    } else if (url.isNotEmpty) {
      image = ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (_, _, _) => fallback,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : fallback,
        ),
      );
    } else {
      image = fallback;
    }

    return Semantics(
      image: true,
      label: fullName,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            image,
            if (showEditBadge)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: FvColors.primary,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.initials, required this.radius});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: context.fvWash,
        shape: BoxShape.circle,
        border: Border.all(color: context.fvCardBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
          color: context.fvPrimary,
        ),
      ),
    );
  }
}
