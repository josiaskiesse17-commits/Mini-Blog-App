import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/article_image_service_provider.dart';
import 'article_image.dart';

class ArticleForm extends ConsumerStatefulWidget {
  const ArticleForm({
    super.key,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialImageId,
    required this.onSubmit,
    this.isLoading = false,
  });

  final String initialTitle;
  final String initialContent;
  final String? initialImageId;

  final Future<void> Function(
    String title,
    String content,
    String? imageId,
  ) onSubmit;

  final bool isLoading;

  @override
  ConsumerState<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends ConsumerState<ArticleForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  String? _imageId;
  bool _isPickingImage = false;
  bool _isRemovingImage = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.initialTitle,
    );

    _contentController = TextEditingController(
      text: widget.initialContent,
    );

    _imageId = widget.initialImageId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage || widget.isLoading) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final service = ref.read(articleImageServiceProvider);

      final newImageId = await service.pickAndSaveImage();

      if (!mounted) {
        return;
      }

      if (newImageId != null && newImageId.isNotEmpty) {
        final previousImageId = _imageId;

        setState(() {
          _imageId = newImageId;
        });

        if (previousImageId != null &&
            previousImageId.isNotEmpty &&
            previousImageId != newImageId) {
          await service.deleteImage(previousImageId);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _removeImage() async {
    final imageId = _imageId;

    if (imageId == null ||
        imageId.isEmpty ||
        _isRemovingImage ||
        widget.isLoading) {
      return;
    }

    setState(() {
      _isRemovingImage = true;
    });

    try {
      await ref
          .read(articleImageServiceProvider)
          .deleteImage(imageId);

      if (!mounted) {
        return;
      }

      setState(() {
        _imageId = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRemovingImage = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (widget.isLoading) {
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    await widget.onSubmit(
      title,
      content,
      _imageId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final hasImage = _imageId != null && _imageId!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Titre',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          enabled: !widget.isLoading,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Titre de l\'article',
            prefixIcon: Icon(Icons.title_rounded),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Contenu',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          enabled: !widget.isLoading,
          minLines: 8,
          maxLines: 14,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Contenu de l\'article',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 120),
              child: Icon(Icons.article_outlined),
            ),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Image de couverture',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        // Displays the current image immediately.
        // When a new image is selected, _imageId changes
        // and this widget rebuilds with the new image.
        ArticleImage(
          imageId: _imageId,
          height: 220,
          borderRadius: 16,
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: widget.isLoading || _isPickingImage
                  ? null
                  : _pickImage,
              icon: _isPickingImage
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      hasImage
                          ? Icons.change_circle_outlined
                          : Icons.add_photo_alternate_outlined,
                    ),
              label: Text(
                _isPickingImage
                    ? 'Sélection...'
                    : hasImage
                        ? 'Changer l\'image'
                        : 'Choisir une image',
              ),
            ),
            if (hasImage)
              OutlinedButton.icon(
                onPressed:
                    widget.isLoading || _isRemovingImage
                        ? null
                        : _removeImage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                ),
                icon: _isRemovingImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.delete_outline_rounded),
                label: Text(
                  _isRemovingImage
                      ? 'Suppression...'
                      : 'Supprimer',
                ),
              ),
          ],
        ),

        const SizedBox(height: 28),

        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: widget.isLoading ? null : _submit,
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }
}