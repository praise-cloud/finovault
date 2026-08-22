import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Brand vault-wheel mark (docs 06-BRAND-GUIDELINES.md). A blue circle divided
/// into a rotating dial segment with a centered keyhole dot.
class VaultMark extends StatelessWidget {
  const VaultMark({super.key, this.size = 48, this.subdued = false});

  final double size;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    final stroke = subdued ? FvColors.textSecondaryDark : FvColors.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _VaultMarkPainter(stroke)),
    );
  }
}

class _VaultMarkPainter extends CustomPainter {
  const _VaultMarkPainter(this.stroke);

  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.052
      ..strokeCap = StrokeCap.round
      ..color = stroke;

    // Outer ring.
    canvas.drawCircle(center, size.width * 0.4375, paint);

    // Dial arc from 12 o'clock sweeping clockwise ~30°.
    final rect = Rect.fromCircle(center: center, radius: size.width * 0.375);
    canvas.drawArc(rect, -_deg(90), _deg(30), false, paint);

    // Keyhole dot.
    canvas.drawCircle(center, size.width * 0.094, Paint()..color = stroke);
  }

  static double _deg(double deg) => deg * 3.141592653589793 / 180;

  @override
  bool shouldRepaint(covariant _VaultMarkPainter oldDelegate) =>
      oldDelegate.stroke != stroke;
}