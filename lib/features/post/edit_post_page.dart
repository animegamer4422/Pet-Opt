import 'package:flutter/material.dart';
import '../../data/post_store.dart';
import '../../models/post.dart';

class EditPostPage extends StatefulWidget {
  final Post post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late final TextEditingController _title;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.post.title);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = _title.text.trim();
    if (v.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    setState(() => _saving = true);

    PostStore.instance.updatePost(postId: widget.post.id, title: v);

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    setState(() => _saving = false);
    Navigator.pop(context);
  }

  void _delete() {
    PostStore.instance.deletePost(widget.post.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit post'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            onPressed: _saving ? null : _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.post.media.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: Image.asset(
                  widget.post.media.first.path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: cs.outlineVariant),
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title *',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_saving ? 'Saving…' : 'Save changes'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        ],
      ),
    );
  }
}
