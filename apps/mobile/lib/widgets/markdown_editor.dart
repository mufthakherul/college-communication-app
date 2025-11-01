import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// A markdown editor widget with formatting toolbar and live preview
class MarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool showPreview;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.hintText = 'Enter content...',
    this.showPreview = true,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  bool _isPreviewMode = false;

  void _insertMarkdown(String before, String after, {String? placeholder}) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final selectedText = selection.textInside(text);
    final content = selectedText.isEmpty ? (placeholder ?? '') : selectedText;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before$content$after',
    );

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + before.length + content.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formatting toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: 'Bold',
                  onPressed: () =>
                      _insertMarkdown('**', '**', placeholder: 'bold text'),
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: 'Italic',
                  onPressed: () =>
                      _insertMarkdown('*', '*', placeholder: 'italic text'),
                ),
                const VerticalDivider(width: 16),
                _buildToolbarButton(
                  icon: Icons.format_list_bulleted,
                  tooltip: 'Bullet list',
                  onPressed: () =>
                      _insertMarkdown('- ', '\n', placeholder: 'list item'),
                ),
                _buildToolbarButton(
                  icon: Icons.format_list_numbered,
                  tooltip: 'Numbered list',
                  onPressed: () =>
                      _insertMarkdown('1. ', '\n', placeholder: 'list item'),
                ),
                const VerticalDivider(width: 16),
                _buildToolbarButton(
                  icon: Icons.link,
                  tooltip: 'Link',
                  onPressed: () =>
                      _insertMarkdown('[', '](url)', placeholder: 'link text'),
                ),
                _buildToolbarButton(
                  icon: Icons.code,
                  tooltip: 'Code',
                  onPressed: () =>
                      _insertMarkdown('`', '`', placeholder: 'code'),
                ),
                const VerticalDivider(width: 16),
                if (widget.showPreview)
                  _buildToolbarButton(
                    icon: _isPreviewMode ? Icons.edit : Icons.visibility,
                    tooltip: _isPreviewMode ? 'Edit' : 'Preview',
                    onPressed: () {
                      setState(() => _isPreviewMode = !_isPreviewMode);
                    },
                  ),
              ],
            ),
          ),
        ),
        // Editor/Preview area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
            child: _isPreviewMode ? _buildPreview() : _buildEditor(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Supports: **bold**, *italic*, [links](url), - lists, 1. numbered lists, `code`',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Widget _buildEditor() {
    return TextField(
      controller: widget.controller,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildPreview() {
    return widget.controller.text.isEmpty
        ? Center(
            child: Text(
              'Nothing to preview',
              style: TextStyle(color: Colors.grey[400]),
            ),
          )
        : Markdown(
            data: widget.controller.text,
            padding: const EdgeInsets.all(12),
            shrinkWrap: false,
          );
  }
}
