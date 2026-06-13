import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../models/bump_photo.dart';
import '../../state/app_state.dart';

class BumpPhotosScreen extends ConsumerWidget {
  const BumpPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(bumpPhotosProvider);
    final profile = ref.watch(profileProvider);
    final week = profile?.currentWeek(DateTime.now()) ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Scaffold(
      appBar: AppBar(title: const Text('Bump Photos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPhoto(context, ref, week),
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Add photo'),
      ),
      body: photos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        size: 64, color: mutedColor),
                    const SizedBox(height: 16),
                    Text('No bump photos yet',
                        style: TextStyle(
                            color: mutedColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      'Capture your journey week by week.\nPhotos are stored only on your device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: mutedColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          : _PhotoGrid(photos: photos),
    );
  }

  Future<void> _addPhoto(
      BuildContext context, WidgetRef ref, int week) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (xfile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'bump_photos'));
    if (!photosDir.existsSync()) {
      await photosDir.create(recursive: true);
    }

    final ext = p.extension(xfile.path).isEmpty ? '.jpg' : p.extension(xfile.path);
    final filename = 'bump_w${week}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final saved = await File(xfile.path).copy(p.join(photosDir.path, filename));

    final photo = BumpPhoto(
      id: const Uuid().v4(),
      date: DateTime.now(),
      week: week,
      filePath: saved.path,
    );

    await ref.read(bumpPhotosProvider.notifier).add(photo);
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos});
  final List<BumpPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final photo = photos[i];
        final file = File(photo.filePath);
        final exists = file.existsSync();

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: exists
                ? () => _openDetail(context, photo)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: exists
                      ? Image.file(file, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: Icon(Icons.broken_image_rounded,
                              color: mutedColor, size: 40),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Week ${photo.week}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(DateFormat.MMMd().format(photo.date),
                          style: TextStyle(
                              color: mutedColor, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, BumpPhoto photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoDetailScreen(photo: photo),
      ),
    );
  }
}

class _PhotoDetailScreen extends StatelessWidget {
  const _PhotoDetailScreen({required this.photo});
  final BumpPhoto photo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.black,
      appBar: AppBar(
        title: Text('Week ${photo.week}'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image.file(
                  File(photo.filePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: isDark ? AppColors.surfaceDark : Colors.black87,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week ${photo.week} · ${DateFormat.yMMMMd().format(photo.date)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                  if (photo.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(photo.note,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
