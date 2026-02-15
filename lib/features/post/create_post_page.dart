import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();

  final _picker = ImagePicker();
  final List<MediaItem> _media = [];

  bool _posting = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

void _showAddMediaSheet() {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Add images'),
                subtitle: const Text('Select one or more photos'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _addImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Add video'),
                subtitle: const Text('Select a video clip'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _addVideo();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Future<void> _addImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;

    setState(() {
      _media.addAll(images.map((x) => MediaItem(type: MediaType.image, path: x.path)));
    });
  }

  Future<void> _addVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    setState(() {
      _media.add(MediaItem(type: MediaType.video, path: video.path));
    });
  }

  void _removeAt(int i) {
    setState(() => _media.removeAt(i));
  }

  Future<void> _submit() async {
    if (_media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image/video.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _posting = true);

    // TODO: upload media + create post in backend
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _posting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Posted (mock)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Media pickers
FilledButton.icon(
  onPressed: _posting ? null : _showAddMediaSheet,
  icon: const Icon(Icons.add_photo_alternate),
  label: const Text('Add media'),
  style: FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
),

          const SizedBox(height: 14),

          // Media required hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.onSurface.withOpacity(0.7)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('At least one image/video is required to post.'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Media preview grid
          if (_media.isNotEmpty)
            _MediaGrid(
              items: _media,
              onRemove: _removeAt,
            ),

          if (_media.isNotEmpty) const SizedBox(height: 18),

          // Title
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Post title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              textInputAction: TextInputAction.done,
            ),
          ),

          const SizedBox(height: 22),

          FilledButton.icon(
            onPressed: _posting ? null : _submit,
            icon: _posting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_posting ? 'Posting…' : 'Post'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final List<MediaItem> items;
  final void Function(int index) onRemove;

  const _MediaGrid({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: cs.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    item.type == MediaType.image ? Icons.image : Icons.videocam,
                    size: 28,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: cs.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onRemove(i),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, size: 16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
