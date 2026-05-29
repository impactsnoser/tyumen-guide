import 'dart:io';

import 'package:image/image.dart' as img;

/// Crops the provided PNG to a clean square icon without caption/star,
/// then resizes to 1024x1024 and writes to assets/app_icon.png.
///
/// Input image is expected to be 1024x1024 with caption at the bottom.
void main() {
  final input = File(
    r'C:\Users\Колледж Skypro\.cursor\projects\c\assets\c__Users_________Skypro_AppData_Roaming_Cursor_User_workspaceStorage_8b705fecfdf7c51e920762f9be16d451_images_image-d9f571fe-d5d8-4b9d-b2ed-3529a13d1ac8.png',
  );

  if (!input.existsSync()) {
    stderr.writeln('Input not found: ${input.path}');
    exit(1);
  }

  final bytes = input.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode image.');
    exit(1);
  }

  // Manually tuned crop to remove the caption ("Вариант 1...") and the star.
  // Crop a centered square that contains the rounded icon.
  const left = 92;
  const top = 60;
  const size = 840; // 840x840

  final cropped = img.copyCrop(
    decoded,
    x: left,
    y: top,
    width: size,
    height: size,
  );

  final resized = img.copyResize(
    cropped,
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.cubic,
  );

  final outDir = Directory('assets');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final outFile = File('assets/app_icon.png');
  outFile.writeAsBytesSync(img.encodePng(resized, level: 6));
  stdout.writeln('Wrote ${outFile.path}');
}

