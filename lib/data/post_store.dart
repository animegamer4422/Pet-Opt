import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/post.dart';

class PostStore extends ChangeNotifier {
  PostStore._();
  static final PostStore instance = PostStore._();

  final List<Post> _posts = [];
  final Random _r = Random();

  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  void seedMockIfEmpty() {
    if (_posts.isNotEmpty) return;

    _posts.addAll([
      Post(
        id: 'seed-1',
        title: 'Friendly pup looking for a home 🐶',
        authorName: 'Community',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likeCount: 12,
        commentCount: 3,
        media: const [
          // If these assets don't exist, your Feed _ImageLayer should fall back safely.
          MediaItem(type: MediaType.image, path: 'assets/mock/dog1.jpg'),
          MediaItem(type: MediaType.image, path: 'assets/mock/dog2.jpg'),
        ],
      ),
      Post(
        id: 'seed-2',
        title: 'Rescued kitten — playful & vaccinated 😺',
        authorName: 'Community',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        likeCount: 41,
        commentCount: 9,
        media: const [
          MediaItem(type: MediaType.image, path: 'assets/mock/cat1.jpg'),
        ],
      ),
    ]);

    notifyListeners();
  }

  Future<void> refresh() async {
    // Demo: simulate a refresh; keep state stable
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Demo cap
      if (_posts.length > 25) {
        _hasMore = false;
        return;
      }

      final now = DateTime.now();

      final newPosts = List.generate(6, (i) {
        final id = 'more-${now.millisecondsSinceEpoch}-$i';
        return Post(
          id: id,
          title: 'New pet post #${_posts.length + i + 1}',
          authorName: 'User${_r.nextInt(999)}',
          createdAt: now.subtract(Duration(minutes: _r.nextInt(3000))),
          likeCount: _r.nextInt(120),
          commentCount: _r.nextInt(30),
          media: const [
            MediaItem(type: MediaType.image, path: 'assets/mock/dog1.jpg'),
          ],
        );
      });

      _posts.addAll(newPosts);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final p = _posts.firstWhere((x) => x.id == postId);
    p.liked = !p.liked;
    p.likeCount += p.liked ? 1 : -1;
    if (p.likeCount < 0) p.likeCount = 0;
    notifyListeners();
  }

  void toggleSave(String postId) {
    final p = _posts.firstWhere((x) => x.id == postId);
    p.saved = !p.saved;
    notifyListeners();
  }

  void updatePost({
  required String postId,
  String? title,
  List<MediaItem>? media,
}) {
  final index = _posts.indexWhere((x) => x.id == postId);
  if (index == -1) return;

  final old = _posts[index];

  final updated = Post(
    id: old.id,
    title: title ?? old.title,
    authorName: old.authorName,
    createdAt: old.createdAt,
    likeCount: old.likeCount,
    commentCount: old.commentCount,
    media: media ?? old.media,
  )
    ..liked = old.liked
    ..saved = old.saved;

  _posts[index] = updated;
  notifyListeners();
}

void claimLegacyYouPosts(String newAuthorName) {
  for (int i = 0; i < _posts.length; i++) {
    final p = _posts[i];

    if (p.authorName == 'You') {
      final updated = Post(
        id: p.id,
        title: p.title,
        authorName: newAuthorName,
        createdAt: p.createdAt,
        likeCount: p.likeCount,
        commentCount: p.commentCount,
        media: p.media,
      )
        ..liked = p.liked
        ..saved = p.saved;

      _posts[i] = updated;
    }
  }

  notifyListeners();
}

void deletePost(String postId) {
  _posts.removeWhere((x) => x.id == postId);
  notifyListeners();
}

}

