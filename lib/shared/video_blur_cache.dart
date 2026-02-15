import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoBlurCache {
  VideoBlurCache._();
  static final instance = VideoBlurCache._();

  final Map<String, Future<File?>> _inFlight = {};

  /// Returns a cached blurred thumbnail file for [videoPath], generating it once if needed.
  Future<File?> getBlurredThumbFile(
    String videoPath, {
    int width = 480,
    int blurRadius = 20, // image blur, not UI blur
    int quality = 80,
  }) {
    return _inFlight.putIfAbsent(
      _cacheKey(videoPath, width, blurRadius, quality),
      () async {
        try {
          final f = File(videoPath);
          if (!f.existsSync()) return null;

          final cacheDir = await _cacheDir();
          final key = _cacheKey(videoPath, width, blurRadius, quality);
          final out = File('${cacheDir.path}/$key.jpg');

          if (out.existsSync() && out.lengthSync() > 0) return out;

          // 1) Extract a single frame thumbnail from the video
          final Uint8List? thumbBytes = await VideoThumbnail.thumbnailData(
            video: videoPath,
            imageFormat: ImageFormat.JPEG,
            maxWidth: width,
            quality: quality,
            timeMs: 250,
          );

          if (thumbBytes == null) return null;

          // 2) Blur the thumbnail using the `image` package
          final decoded = img.decodeImage(thumbBytes);
          if (decoded == null) return null;

          // Downscale before blur for speed (optional but recommended)
          final resized = img.copyResize(decoded, width: width);
          final blurred = img.gaussianBlur(resized, radius: blurRadius);

          final jpg = img.encodeJpg(blurred, quality: quality);
          await out.writeAsBytes(jpg, flush: true);

          return out;
        } catch (_) {
          return null;
        } finally {
          // Allow regeneration later if needed
          _inFlight.remove(_cacheKey(videoPath, width, blurRadius, quality));
        }
      },
    );
  }

  Future<Directory> _cacheDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/petopt_video_blur_cache');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  String _cacheKey(String videoPath, int width, int blurRadius, int quality) {
    final f = File(videoPath);
    final stat = f.existsSync() ? f.statSync() : null;
    final stamp = stat == null
        ? 'na'
        : '${stat.modified.millisecondsSinceEpoch}_${stat.size}';

    final raw = '$videoPath|$stamp|w=$width|b=$blurRadius|q=$quality';
    return sha1.convert(raw.codeUnits).toString();
  }
}
