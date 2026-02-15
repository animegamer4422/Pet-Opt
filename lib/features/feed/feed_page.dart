import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/post.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // Mock posts for now. Later: load from backend / local storage.
  final List<Post> posts = const [
    Post(
      id: '1',
      title: 'Friendly indie pup looking for a home 🐶',
      media: [
        MediaItem(type: MediaType.image, path: 'assets/mock/dog1.jpg'),
        MediaItem(type: MediaType.image, path: 'assets/mock/dog2.jpg'),
      ],
    ),
    Post(
      id: '2',
      title: 'Rescued kitten — playful & vaccinated 😺',
      media: [
        MediaItem(type: MediaType.image, path: 'assets/mock/cat1.jpg'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PetOpt')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => PostCard(post: posts[i]),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: MediaCarousel(
                  postId: post.id,
                  media: post.media,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ActionChip(icon: Icons.favorite_border, label: 'Interested'),
                const SizedBox(width: 8),
                _ActionChip(icon: Icons.chat_bubble_outline, label: 'Message'),
                const Spacer(),
                Icon(Icons.more_horiz, color: cs.onSurface.withOpacity(0.65)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class MediaCarousel extends StatefulWidget {
  final String postId;
  final List<MediaItem> media;

  const MediaCarousel({
    super.key,
    required this.postId,
    required this.media,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  late final PageController _page;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _page = PageController();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _openViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenMediaViewer(
          postId: widget.postId,
          media: widget.media,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        PageView.builder(
          controller: _page,
          itemCount: widget.media.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final item = widget.media[i];
            return GestureDetector(
              onTap: () => _openViewer(i),
              child: RedditBlurMediaTile(
                heroTag: 'post_${widget.postId}_$i',
                item: item,
              ),
            );
          },
        ),

        if (widget.media.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.media.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 7,
                  width: active ? 18 : 7,
                  decoration: BoxDecoration(
                    color: active ? cs.primary : cs.onSurface.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),

        if (widget.media.length > 1)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_index + 1}/${widget.media.length}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class RedditBlurMediaTile extends StatelessWidget {
  final String heroTag;
  final MediaItem item;

  const RedditBlurMediaTile({
    super.key,
    required this.heroTag,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    Widget background;

    if (item.type == MediaType.image) {
      background = _ImageLayer(
        path: item.path,
        fit: BoxFit.cover,
      );
    } else {
      background = Container(color: Colors.black);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 🔹 Step 1: Raw background image (cover)
        background,

        // 🔹 Step 2: Proper Gaussian blur on background
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 35, // 🔥 real blur intensity
                sigmaY: 35,
              ),
              child: Container(
                color: Colors.transparent, // IMPORTANT: no dimming
              ),
            ),
          ),
        ),

        // 🔹 Step 3: Foreground image (contain, sharp)
        Center(
          child: Hero(
            tag: heroTag,
            child: _ForegroundMedia(item: item),
          ),
        ),
      ],
    );
  }
}

class _ForegroundMedia extends StatelessWidget {
  final MediaItem item;
  const _ForegroundMedia({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.type == MediaType.image) {
      return _ImageLayer(path: item.path, fit: BoxFit.contain);
    }
    return _InlineVideo(path: item.path);
  }
}

class _ImageLayer extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const _ImageLayer({required this.path, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit);
    }
    return Image.file(File(path), fit: fit);
  }
}

class _InlineVideo extends StatefulWidget {
  final String path;
  const _InlineVideo({required this.path});

  @override
  State<_InlineVideo> createState() => _InlineVideoState();
}

class _InlineVideoState extends State<_InlineVideo> {
  VideoPlayerController? _c;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.file(File(widget.path))
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.play_circle_fill, size: 72, color: Colors.white),
        ),
      ],
    );
  }
}

class FullscreenMediaViewer extends StatefulWidget {
  final String postId;
  final List<MediaItem> media;
  final int initialIndex;

  const FullscreenMediaViewer({
    super.key,
    required this.postId,
    required this.media,
    required this.initialIndex,
  });

  @override
  State<FullscreenMediaViewer> createState() => _FullscreenMediaViewerState();
}

class _FullscreenMediaViewerState extends State<FullscreenMediaViewer> {
  late final PageController _page;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _page = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _page,
              itemCount: widget.media.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final item = widget.media[i];
                final heroTag = 'post_${widget.postId}_$i';

                return Center(
                  child: Hero(
                    tag: heroTag,
                    child: item.type == MediaType.image
                        ? _FullscreenImage(path: item.path)
                        : _FullscreenVideo(path: item.path),
                  ),
                );
              },
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Spacer(),
                    if (widget.media.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Text(
                          '${_index + 1}/${widget.media.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  final String path;
  const _FullscreenImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final image = path.startsWith('assets/')
        ? Image.asset(path)
        : Image.file(File(path));

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: image,
    );
  }
}

class _FullscreenVideo extends StatefulWidget {
  final String path;
  const _FullscreenVideo({required this.path});

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  VideoPlayerController? _c;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.file(File(widget.path))
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _c?.play();
      });
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
      child: Stack(
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          ),
          if (!c.value.isPlaying)
            const Center(
              child: Icon(Icons.play_circle_fill, size: 84, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
