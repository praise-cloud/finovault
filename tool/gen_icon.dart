// Renders the Finovault VaultMark (blue vault wheel) as the Android/iOS app
// icon on a white field, matching the app's home-page hero brand mark
// (widgets/vault_mark.dart) and brand blue #1D4ED8.
//
// Run from the flutter project root:
//   dart run tool/gen_icon.dart
//
// Writes:
//   tool/assets/app_icon_256.png, _512.png, _1024.png   (masters)
//   android/app/src/main/res/mipmap-*/ic_launcher.png   (per density)
//   ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-*.png
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const double _kPi = math.pi;

void _emitDots(
  img.Image out,
  double cx,
  double cy,
  double radius,
  double stroke,
  double startDeg,
  double sweepDeg,
  img.Color color,
) {
  final half = stroke / 2;
  // Sample closely so filled dots join into a continuous stroke.
  final circumference = 2 * _kPi * radius;
  final steps = (circumference / 1.5).ceil();
  for (var i = 0; i <= steps; i++) {
    final rad = (startDeg + (sweepDeg * i / steps)) * (_kPi / 180);
    final x = cx + radius * math.cos(rad);
    final y = cy + radius * math.sin(rad);
    img.fillCircle(
      out,
      x: x.round(),
      y: y.round(),
      radius: half.round(),
      color: color,
      antialias: true,
    );
  }
}

img.Image render(int size) {
  final out = img.Image(width: size, height: size);
  img.fill(out, color: img.ColorRgba8(255, 255, 255, 255));

  final cx = size / 2;
  final cy = size / 2;
  final stroke = size * 0.052;
  final ringRadius = size * 0.4375;
  final dialRadius = size * 0.375;
  final keyholeRadius = size * 0.094;

  final ink = img.ColorRgba8(0x1D, 0x4E, 0xD8, 255);

  // Outer ring (full 360deg).
  _emitDots(out, cx, cy, ringRadius, stroke, 0, 360, ink);
  // Dial arc: from 12 o'clock sweeping 30deg clockwise (start -90deg).
  _emitDots(out, cx, cy, dialRadius, stroke, -90, 30, ink);
  // Keyhole dot (filled).
  img.fillCircle(
    out,
    x: cx.round(),
    y: cy.round(),
    radius: keyholeRadius.round(),
    color: ink,
    antialias: true,
  );

  return img.flipVertical(out);
}

void _savePng(img.Image i, String path) {
  File(path).parent.createSync(recursive: true);
  File(path).writeAsBytesSync(img.encodePng(i));
}

void main() {
  final root = Directory.current.path;

  // Resolve tool dir (script lives under <root>/tool).
  final toolDir = '${root}${Platform.pathSeparator}tool';

  // Render masters at 256/512/1024 for reference + storefront.
  final m1024 = render(1024);
  _savePng(
    m1024,
    '$toolDir${Platform.pathSeparator}assets${Platform.pathSeparator}app_icon_1024.png',
  );

  final iconsDir = '$toolDir${Platform.pathSeparator}assets';
  // Play store wants 512.
  _savePng(
    img.copyResize(
      m1024,
      width: 512,
      height: 512,
      interpolation: img.Interpolation.cubic,
    ),
    '$iconsDir${Platform.pathSeparator}app_icon_512.png',
  );
  _savePng(
    img.copyResize(
      m1024,
      width: 256,
      height: 256,
      interpolation: img.Interpolation.cubic,
    ),
    '$iconsDir${Platform.pathSeparator}app_icon_256.png',
  );

  // Android launcher mipmaps (48/72/96/144/192).
  const densities = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  final safe = render(192);
  for (final e in densities.entries) {
    var sized = safe;
    if (e.value != 192) {
      sized = img.copyResize(
        safe,
        width: e.value,
        height: e.value,
        interpolation: img.Interpolation.cubic,
      );
    }
    _savePng(
      sized,
      '$root${Platform.pathSeparator}android${Platform.pathSeparator}app${Platform.pathSeparator}src${Platform.pathSeparator}main${Platform.pathSeparator}res${Platform.pathSeparator}${e.key}${Platform.pathSeparator}ic_launcher.png',
    );
  }

  // iOS AppIcon set: 1024 is all Xcode needs for a single-size universal icon.
  final ios =
      '$root${Platform.pathSeparator}ios${Platform.pathSeparator}Runner${Platform.pathSeparator}Assets.xcassets${Platform.pathSeparator}AppIcon.appiconset';
  _savePng(m1024, '$ios${Platform.pathSeparator}Icon-App-1024@1x.png');

  stdout.writeln('OK  wrote vault-wheel app icons');
  stdout.writeln('  masters     $iconsDir/app_icon_{256,512,1024}.png');
  stdout.writeln(
    '  android     res/mipmap-*/ic_launcher.png (${densities.values.join(',')})',
  );
  stdout.writeln('  ios         AppIcon.appiconset/Icon-App-1024@1x.png');
}
