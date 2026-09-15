import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/providers/article_image_local_data_source_provider.dart';
import '../../data/providers/article_image_service_provider.dart';

class ArticleForm extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final String? initialImageId;
  final Future<void> Function(
    String title,
    String content,
    String? imageId,
  ) onSubmit;
  final bool isLoading;

  const ArticleForm({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.initialImageId,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  ConsumerState<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends ConsumerState<ArticleForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  String? _imageId;
  Uint8List? _imageBytes;
  bool _isPickingImage = false;

  bool get _isEditing => widget.initialTitle != null;

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

    if (_imageId != null) {
      _loadExistingImage(_imageId!);
    }
  }

  Future<void> _loadExistingImage(String imageId) async {
    final imageDataSource =
        ref.read(articleImageLocalDataSourceProvider);

    final bytes = await imageDataSource.getImage(imageId);

    if (!mounted) {
      return;
    }

    setState(() {
      _imageBytes = bytes;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final imageService = ref.read(articleImageServiceProvider);

      final newImageId = await imageService.pickAndSaveImage();

      if (!mounted || newImageId == null) {
        return;
      }

      final bytes = await ref
          .read(articleImageLocalDataSourceProvider)
          .getImage(newImageId);

      if (!mounted) {
        return;
      }

      setState(() {
        _imageId = newImageId;
        _imageBytes = bytes;
      });
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

    if (imageId != null) {
      await ref
          .read(articleImageServiceProvider)
          .deleteImage(imageId);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _imageId = null;
      _imageBytes = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSubmit(
      _titleController.text.trim(),
      _contentController.text.trim(),
      _imageId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditing ? 'Modifier votre article' : 'Nouvel article',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing
                ? 'Modifiez le contenu de votre article.'
                : 'Partagez votre article avec la communauté.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Titre de l\'article',
              hintText: 'Entrez le titre de votre article',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
            maxLength: AppConstants.articleTitleMaxLength,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer un titre';
              }

              if (value.trim().length >
                  AppConstants.articleTitleMaxLength) {
                return 'Le titre ne peut pas dépasser '
                    '${AppConstants.articleTitleMaxLength} caractères';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _contentController,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Contenu',
              hintText: 'Écrivez votre article ici...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 120),
                child: Icon(Icons.article_outlined),
              ),
              border: OutlineInputBorder(),
            ),
            minLines: 8,
            maxLines: 14,
            maxLength: AppConstants.articleContentMaxLength,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer du contenu';
              }

              if (value.trim().length >
                  AppConstants.articleContentMaxLength) {
                return 'Le contenu ne peut pas dépasser '
                    '${AppConstants.articleContentMaxLength} caractères';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          _buildImageSection(context),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: widget.isLoading ? null : _submit,
            icon: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _isEditing
                        ? Icons.save_outlined
                        : Icons.publish_outlined,
                  ),
            label: Text(
              widget.isLoading
                  ? 'Enregistrement...'
                  : _isEditing
                      ? 'Enregistrer les modifications'
                      : 'Publier l\'article',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final theme = Theme.of(context);

    if (_imageBytes == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.image_outlined,
              size: 42,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Image de couverture',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ajoutez une image pour illustrer votre article.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: widget.isLoading || _isPickingImage
                  ? null
                  : _pickImage,
              icon: _isPickingImage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _isPickingImage
                    ? 'Sélection de l\'image...'
                    : 'Ajouter une image',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Image de couverture',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(
              _imageBytes!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 400;

            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        widget.isLoading || _isPickingImage
                            ? null
                            : _pickImage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Remplacer'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed:
                        widget.isLoading ? null : _removeImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        widget.isLoading || _isPickingImage
                            ? null
                            : _pickImage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Remplacer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        widget.isLoading ? null : _removeImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}