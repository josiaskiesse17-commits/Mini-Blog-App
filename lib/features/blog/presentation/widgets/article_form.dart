import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class ArticleForm extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final Future<void> Function(String title, String content) onSubmit;
  final bool isLoading;

  const ArticleForm({
    super.key,
    this.initialTitle,
    this.initialContent,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends State<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await widget.onSubmit(
        _titleController.text.trim(),
        _contentController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre de l\'article',
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
          const SizedBox(height: 16),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Contenu',
              border: OutlineInputBorder(),
            ),
            maxLines: 8,
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
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.isLoading
                ? const CircularProgressIndicator()
                : Text(
                    widget.initialTitle != null
                        ? 'Modifier l\'article'
                        : 'Créer l\'article',
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}
