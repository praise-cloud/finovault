import 'package:flutter/material.dart';

/// Official Finovault 2D brutalist vault mark.
/// Flat geometric brutalist mark featuring the vault hinge barrel,
/// security bolts, cobalt vault coin, and centered geometric "F"
/// with crisp black outlines for clarity on any background.
class VaultMark extends StatelessWidget {
  const VaultMark({super.key, this.size = 48, this.subdued = false});

  final double size;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Finovault',
      child: Opacity(
        opacity: subdued ? 0.35 : 1.0,
        child: SizedBox(
          width: size,
          height: size,
          child: const CustomPaint(painter: _VaultMarkPainter()),
        ),
      ),
    );
  }
}

class _VaultMarkPainter extends CustomPainter {
  const _VaultMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 512.0;

    final inkPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final hingeFill = Paint()
      ..color = const Color(0xFF14239E)
      ..style = PaintingStyle.fill;

    final coinFill = Paint()
      ..color = const Color(0xFF1B3FE0)
      ..style = PaintingStyle.fill;

    final whiteFill = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    // 1. Vault hinge barrel (right side)
    // Rect: x=336, y=150, w=120, h=212, rx=16
    final hingeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(336 * s, 150 * s, 120 * s, 212 * s),
      Radius.circular(16 * s),
    );
    canvas.drawRRect(hingeRect, hingeFill);
    canvas.drawRRect(hingeRect, inkPaint..strokeWidth = 10 * s);

    // Hinge barrel right cap circle: cx=486, cy=256, r=26
    canvas.drawCircle(Offset(486 * s, 256 * s), 26 * s, hingeFill);
    canvas.drawCircle(Offset(486 * s, 256 * s), 26 * s, inkPaint..strokeWidth = 10 * s);

    // Hinge connector rect: x=486, y=246, w=26, h=20
    final capRect = Rect.fromLTWH(486 * s, 246 * s, 26 * s, 20 * s);
    canvas.drawRect(capRect, hingeFill);
    canvas.drawRect(capRect, inkPaint..strokeWidth = 10 * s);

    // Hinge pivot inner circle: cx=486, cy=256, r=10
    canvas.drawCircle(Offset(486 * s, 256 * s), 10 * s, whiteFill);
    canvas.drawCircle(Offset(486 * s, 256 * s), 10 * s, inkPaint..strokeWidth = 6 * s);

    // Hinge bolts: cx=366, r=13 at y=196, 256, 316
    for (final cy in [196.0, 256.0, 316.0]) {
      canvas.drawCircle(Offset(366 * s, cy * s), 13 * s, whiteFill);
      canvas.drawCircle(Offset(366 * s, cy * s), 13 * s, inkPaint..strokeWidth = 6 * s);
    }

    // 2. Main vault-door coin: cx=230, cy=256
    final coinCenter = Offset(230 * s, 256 * s);
    // Outer coin: r=198, strokeWidth=16
    canvas.drawCircle(coinCenter, 198 * s, coinFill);
    canvas.drawCircle(coinCenter, 198 * s, inkPaint..strokeWidth = 16 * s);

    // Inner ring: r=160, strokeWidth=7
    canvas.drawCircle(coinCenter, 160 * s, inkPaint..strokeWidth = 7 * s);

    // 3. Flat geometric "F":
    // points: [ (158.0, 138.0), (305.0, 138.0), (305.0, 185.25), (205.25, 185.25), (205.25, 232.5),
    //           (278.75, 232.5), (278.75, 277.65), (205.25, 277.65), (205.25, 342.75), (158.0, 369.0) ]
    final fPath = Path()
      ..moveTo(158.0 * s, 138.0 * s)
      ..lineTo(305.0 * s, 138.0 * s)
      ..lineTo(305.0 * s, 185.25 * s)
      ..lineTo(205.25 * s, 185.25 * s)
      ..lineTo(205.25 * s, 232.5 * s)
      ..lineTo(278.75 * s, 232.5 * s)
      ..lineTo(278.75 * s, 277.65 * s)
      ..lineTo(205.25 * s, 277.65 * s)
      ..lineTo(205.25 * s, 342.75 * s)
      ..lineTo(158.0 * s, 369.0 * s)
      ..close();

    canvas.drawPath(fPath, whiteFill);
    canvas.drawPath(fPath, inkPaint..strokeWidth = 8 * s);
  }

  @override
  bool shouldRepaint(covariant _VaultMarkPainter oldDelegate) => false;
}
