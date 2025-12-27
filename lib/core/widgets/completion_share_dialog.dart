import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';

class CompletionShareDialog extends StatefulWidget {
  final String title;
  final bool isTvShow;
  final int? season;
  final String? posterPath;

  const CompletionShareDialog({
    super.key,
    required this.title,
    this.isTvShow = false,
    this.season,
    this.posterPath,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    bool isTvShow = false,
    int? season,
    String? posterPath,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CompletionShareDialog(
        title: title,
        isTvShow: isTvShow,
        season: season,
        posterPath: posterPath,
      ),
    );
  }

  @override
  State<CompletionShareDialog> createState() => _CompletionShareDialogState();
}

class _CompletionShareDialogState extends State<CompletionShareDialog> {
  final _shareKey = GlobalKey();
  bool _isSharing = false;

  String get _displayTitle {
    if (widget.isTvShow && widget.season != null) {
      return '${widget.title} (Season ${widget.season})';
    }
    return widget.title;
  }

  int get _hoursUntilDoomsday {
    final now = DateTime.now();
    final difference = AppConstants.doomsdayDate.difference(now);
    return difference.inHours;
  }

  Future<void> _shareAsImage() async {
    setState(() => _isSharing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/movie_complete.png');
      await file.writeAsBytes(bytes);

      if (mounted) Navigator.pop(context);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Just finished $_displayTitle! #BeforeDoom #Doomsday\n\nTrack your MCU journey: https://play.google.com/store/apps/details?id=com.lxmwaniky.doom');
    } catch (e) {
      debugPrint('Share failed: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = _hoursUntilDoomsday;
    final days = hours ~/ 24;

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _shareKey,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.posterPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w300${widget.posterPath}',
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2E7D32),
                        size: 40,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'JUST WATCHED',
                    style: TextStyle(
                      color: Color(0xFFFBB016),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _displayTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Color(0xFF2E7D32),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$days days to Doomsday',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '#BeforeDoom',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share your progress?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSharing ? null : () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
        FilledButton.icon(
          onPressed: _isSharing ? null : _shareAsImage,
          icon: _isSharing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.share, size: 18),
          label: const Text('Share'),
        ),
      ],
    );
  }
}
