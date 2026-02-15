import 'package:flutter/material.dart';

import '../../data/post_store.dart';
import '../../models/post.dart';
import '../onboarding/data/profile_store.dart';
import 'create_post_page.dart';
import 'edit_post_page.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final postStore = PostStore.instance;
    final profileStore = ProfileStore.instance;

    return DefaultTabController(
      length: 2,
      child: AnimatedBuilder(
        animation: Listenable.merge([postStore, profileStore]),
        builder: (context, _) {
          final p = profileStore.profile;
          final displayName =
              (p != null && p.name.trim().isNotEmpty) ? p.name.trim() : 'User';

          final posts = postStore.posts;

          // My posts: support legacy 'You' so older posts still show up.
          final myPosts = posts.where((x) {
            final a = x.authorName.trim();
            return a == displayName || a == 'You';
          }).toList();

          final savedPosts = posts.where((x) => x.saved).toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Posts'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'My Posts (${myPosts.length})'),
                  Tab(text: 'Saved (${savedPosts.length})'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
            ),
            body: TabBarView(
              children: [
                _PostsList(
                  emptyMessage:
                      "You haven't posted anything yet.\nTap Create to make your first post.",
                  posts: myPosts,
                  onTapPost: (post) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditPostPage(post: post)),
                    );
                  },
                ),
                _PostsList(
                  emptyMessage: "You haven't saved any posts yet.",
                  posts: savedPosts,
                  onTapPost: (post) {
                    // For now: open edit for your own saved posts too is fine,
                    // but usually you'd open the viewer/detail page.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditPostPage(post: post)),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  final List<Post> posts;
  final String emptyMessage;
  final void Function(Post post) onTapPost;

  const _PostsList({
    required this.posts,
    required this.emptyMessage,
    required this.onTapPost,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return _EmptyState(message: emptyMessage);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final p = posts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _MiniPostCard(
            post: p,
            onTap: () => onTapPost(p),
          ),
        );
      },
    );
  }
}

class _MiniPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const _MiniPostCard({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final clickable = onTap != null;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (post.media.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset(
                      post.media.first.path,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: cs.outlineVariant),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          post.authorName,
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.favorite,
                            size: 14, color: cs.onSurface.withOpacity(0.55)),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likeCount}',
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.chat_bubble_outline,
                            size: 14, color: cs.onSurface.withOpacity(0.55)),
                        const SizedBox(width: 4),
                        Text(
                          '${post.commentCount}',
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (clickable) ...[
                const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                    color: cs.onSurface.withOpacity(0.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message,
            style: t.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
