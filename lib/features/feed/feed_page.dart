// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/post_store.dart';
import '../../models/post.dart';

import '../../shared/video_blur_cache.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _CachedBlurredVideoBackground extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const _CachedBlurredVideoBackground({
    required this.path,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<File?>(
      future: VideoBlurCache.instance.getBlurredThumbFile(
        path,
        width: 420,
        blurRadius: 18,
        quality: 80,
      ),
      builder: (context, snap) {
        final f = snap.data;
        if (f == null) {
          // fallback (fast)
          return Container(color: cs.surfaceContainerHighest);
        }

        return Image.file(
          f,
          fit: fit,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) => Container(color: cs.surfaceContainerHighest),
        );
      },
    );
  }
}

class _FeedPageState extends State<FeedPage> {
  final _store = PostStore.instance;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _store.seedMockIfEmpty();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 800) {
      _store.loadMore();
    }
  }

  Future<void> _refresh() => _store.refresh();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final posts = _store.posts;

        return Scaffold(
          appBar: AppBar(title: const Text('PetOpt')),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: posts.isEmpty
                ? _EmptyFeed(
                    onCreate: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Go to Post tab to create your first post.')),
                      );
                    },
                  )
                : ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    itemCount: posts.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == posts.length) {
                        if (!_store.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Center(child: Text('You’re all caught up.')),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: _store.isLoadingMore
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      return PostCard(post: posts[i]);
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyFeed({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No posts yet', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(
                'Be the first to post a pet for adoption.',
                style: t.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.75)),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_box),
                label: const Text('Create a post'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = PostStore.instance;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.person, size: 16, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${post.authorName} • ${_timeAgo(post.createdAt)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface.withOpacity(0.85),
                    ),
                  ),
                ),
                Icon(Icons.more_horiz, color: cs.onSurface.withOpacity(0.65)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: MediaCarousel(postId: post.id, media: post.media),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _IconStatButton(
                  icon: post.liked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likeCount}',
                  onTap: () => store.toggleLike(post.id),
                ),
                const SizedBox(width: 10),
                _IconStatButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentCount}',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comments screen next')),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _IconStatButton(
                  icon: Icons.ios_share,
                  label: 'Share',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share action later')),
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => store.toggleSave(post.id),
                  icon: Icon(post.saved ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconStatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconStatButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
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
    final isImage = item.type == MediaType.image;

      final Widget background = isImage
          ? _ImageLayer(path: item.path, fit: BoxFit.cover)
          : _CachedBlurredVideoBackground(
              path: item.path,
              fit: BoxFit.cover,
            );

    final Widget foreground = isImage
        ? _ImageLayer(path: item.path, fit: BoxFit.contain)
        : _VideoPreviewFrame(
            key: ValueKey('fg_${item.path}'),
            path: item.path,
            fit: BoxFit.contain,
            showPlayOverlay: true,
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        // Keep BackdropFilter only for images (video already pre-blurred).
          if (isImage)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
        Center(
          child: Hero(tag: heroTag, child: foreground),
        ),
      ],
    );
  }
}

class _VideoPreviewFrame extends StatefulWidget {
  final String path;
  final BoxFit fit;
  final bool showPlayOverlay;

  const _VideoPreviewFrame({
    super.key,
    required this.path,
    required this.fit,
    this.showPlayOverlay = true,
  });

  @override
  State<_VideoPreviewFrame> createState() => _VideoPreviewFrameState();
}

class _VideoPreviewFrameState extends State<_VideoPreviewFrame> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _c;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _VideoPreviewFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _c?.dispose();
      _c = null;
      _init();
    }
  }

  Future<void> _init() async {
    final file = File(widget.path);
    if (!file.existsSync()) return;

    final controller = VideoPlayerController.file(file);
    _c = controller;

    await controller.initialize();
    if (!mounted) return;

    final dur = controller.value.duration;
    final target = dur > const Duration(milliseconds: 250) ? const Duration(milliseconds: 250) : Duration.zero;

    await controller.setLooping(false);
    await controller.setVolume(0);
    await controller.seekTo(target);
    await controller.pause();

    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final c = _c;

    Widget fallback() => Stack(
          fit: StackFit.expand,
          children: const [
            DecoratedBox(decoration: BoxDecoration(color: Colors.black)),
            Center(child: Icon(Icons.play_circle_fill, size: 72, color: Colors.white)),
          ],
        );

    if (c == null || !c.value.isInitialized) return fallback();

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
        ),
        if (widget.showPlayOverlay) ...[
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.12))),
          const Center(child: Icon(Icons.play_circle_fill, size: 72, color: Colors.white)),
        ],
      ],
    );
  }
}

class _ImageLayer extends StatelessWidget {
  final String path;
  final BoxFit fit;
  const _ImageLayer({required this.path, required this.fit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget fallback() => Container(
          color: cs.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.pets,
              size: 48,
              color: cs.onSurface.withOpacity(0.35),
            ),
          ),
        );

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stack) => fallback(),
      );
    }

    final f = File(path);
    if (!f.existsSync()) return fallback();

    return Image.file(
      f,
      fit: fit,
      errorBuilder: (context, error, stack) => fallback(),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               FULLSCREEN VIEW                              */
/* -------------------------------------------------------------------------- */


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

  bool _uiVisible = true;
  Timer? _hideTimer;

  // swipe-to-dismiss
  double _dragDy = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _page = PageController(initialPage: widget.initialIndex);
    _armAutoHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _armAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _uiVisible = false);
    });
  }

  void _setUiVisible(bool v) {
    if (_uiVisible == v) return;
    setState(() => _uiVisible = v);
  }

  void _toggleUi() {
    _setUiVisible(!_uiVisible);
    if (!_uiVisible) {
      _hideTimer?.cancel();
    } else {
      _armAutoHide();
    }
  }

  void _showUi() {
    _setUiVisible(true);
    _armAutoHide();
  }

  void _onDragStart(DragStartDetails d) {
    _dragging = true;
    _dragDy = 0;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    // only consider downward drag
    final next = (_dragDy + d.delta.dy);
    if (next < 0) return;

    setState(() => _dragDy = next);
  }

  void _onDragEnd(DragEndDetails d) {
    _dragging = false;

    // dismiss threshold + velocity threshold
    final v = d.velocity.pixelsPerSecond.dy;
    final shouldDismiss = _dragDy > 140 || v > 900;

    if (shouldDismiss) {
      Navigator.pop(context);
      return;
    }

    // snap back
    setState(() => _dragDy = 0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          // swipe down to dismiss
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,

          // tap toggles UI only
          onTap: _toggleUi,
          behavior: HitTestBehavior.opaque,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _dragDy, 0),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _page,
                  itemCount: widget.media.length,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    _showUi();
                  },
                  itemBuilder: (context, i) {
                    final item = widget.media[i];
                    final heroTag = 'post_${widget.postId}_$i';

                    final isImage = item.type == MediaType.image;

                    final Widget bg = isImage
                        ? _ImageLayer(path: item.path, fit: BoxFit.cover)
                        : _CachedBlurredVideoBackground(path: item.path, fit: BoxFit.cover); 

                    final Widget fg = isImage
                        ? _FullscreenImage(
                            path: item.path,
                            onUserInteract: _showUi,
                          )
                        : _FullscreenVideo(
                            path: item.path,
                            uiVisible: _uiVisible,
                            onUserInteract: _showUi,
                          );

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        bg,
                        Positioned.fill(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ),
                        Center(child: Hero(tag: heroTag, child: fg)),
                      ],
                    );
                  },
                ),

                // Top bar
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SafeArea(
                    bottom: false,
                    child: AnimatedOpacity(
                      opacity: _uiVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: IgnorePointer(
                        ignoring: !_uiVisible,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
                    ),
                  ),
                ),

                // Dots indicator
                if (widget.media.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: AnimatedOpacity(
                        opacity: _uiVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 160),
                        child: IgnorePointer(
                          ignoring: !_uiVisible,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
                                    color: active ? cs.primary : Colors.white.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // subtle dim while dragging (feels like native dismiss)
                if (_dragDy > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withOpacity(
                          (0.25 * (1 - (_dragDy / 240).clamp(0.0, 1.0))),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _FullscreenImage extends StatelessWidget {
  final String path;
  final VoidCallback onUserInteract;

  const _FullscreenImage({
    required this.path,
    required this.onUserInteract,
  });

  @override
  Widget build(BuildContext context) {
    final image = path.startsWith('assets/') ? Image.asset(path) : Image.file(File(path));

    // NOTE: taps are handled by parent to toggle UI.
    // We still call onUserInteract on scale/pan start to keep UI alive while interacting.
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      onInteractionStart: (_) => onUserInteract(),
      child: image,
    );
  }
}

class _FullscreenVideo extends StatefulWidget {
  final String path;
  final bool uiVisible;
  final VoidCallback onUserInteract;

  const _FullscreenVideo({
    required this.path,
    required this.uiVisible,
    required this.onUserInteract,
  });

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  VideoPlayerController? _c;

  bool _muted = false;
  bool _isScrubbing = false;
  double _scrubValueMs = 0;

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

    _c?.addListener(_tick);
  }

  void _tick() {
    if (!mounted) return;
    if (_isScrubbing) return;
    setState(() {});
  }

  @override
  void dispose() {
    _c?.removeListener(_tick);
    _c?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$m:${two(s)}';
  }

  Future<void> _toggleMute() async {
    final c = _c;
    if (c == null) return;
    widget.onUserInteract();
    _muted = !_muted;
    await c.setVolume(_muted ? 0 : 1);
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    final c = _c;
    if (c == null) return;
    widget.onUserInteract();
    setState(() {
      c.value.isPlaying ? c.pause() : c.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final v = c.value;
    final pos = v.position;
    final dur = v.duration;

    final durMs = dur.inMilliseconds.clamp(1, 1 << 31);
    final posMs = pos.inMilliseconds.clamp(0, durMs);
    final sliderValue = _isScrubbing ? _scrubValueMs : posMs.toDouble();

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: v.size.width,
              height: v.size.height,
              child: VideoPlayer(c),
            ),
          ),
        ),

        if (v.isBuffering)
          const Center(
            child: SizedBox(height: 26, width: 26, child: CircularProgressIndicator(strokeWidth: 2)),
          ),

        // IMPORTANT: no "tap to pause" layer here.
        // Parent tap toggles UI visibility.

        // Controls OVERLAY pinned to bottom with safe area
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: AnimatedOpacity(
              opacity: widget.uiVisible ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: IgnorePointer(
                ignoring: !widget.uiVisible,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.00),
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          min: 0,
                          max: durMs.toDouble(),
                          value: sliderValue.clamp(0, durMs.toDouble()),
                          onChangeStart: (v) {
                            widget.onUserInteract();
                            setState(() {
                              _isScrubbing = true;
                              _scrubValueMs = v;
                            });
                          },
                          onChanged: (v) {
                            widget.onUserInteract();
                            setState(() => _scrubValueMs = v);
                          },
                          onChangeEnd: (v) async {
                            widget.onUserInteract();
                            final c = _c;
                            if (c == null) return;
                            await c.seekTo(Duration(milliseconds: v.toInt()));
                            setState(() => _isScrubbing = false);
                          },
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _togglePlayPause,
                            icon: Icon(v.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: _toggleMute,
                            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_fmt(pos)} / ${_fmt(dur)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
