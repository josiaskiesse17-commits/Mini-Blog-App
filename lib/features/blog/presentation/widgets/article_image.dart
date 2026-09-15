import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/article_image_local_data_source_provider.dart';

class ArticleImage extends ConsumerWidget {
  const ArticleImage({
    super.key,
    required this.imageId,
    this.height = 220,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String? imageId;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageId == null || imageId!.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Uint8List?>(
      future: ref
          .read(articleImageLocalDataSourceProvider)
          .getImage(imageId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bytes = snapshot.data;

        if (bytes == null || bytes.isEmpty) {
          return const SizedBox.shrink();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            bytes,
            width: double.infinity,
            height: height,
            fit: fit,
          ),
        );
      },
    );
  }
}