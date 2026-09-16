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
      return _placeholder(context);
    }

    return FutureBuilder<Uint8List?>(
      future: ref
          .read(articleImageLocalDataSourceProvider)
          .getImage(imageId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading(context);
        }

        final bytes = snapshot.data;

        if (bytes == null || bytes.isEmpty) {
          return _placeholder(context);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            bytes,
            width: double.infinity,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _placeholder(context),
          ),
        );
      },
    );
  }

  Widget _loading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colors.primary,
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 42,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Image de couverture',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}