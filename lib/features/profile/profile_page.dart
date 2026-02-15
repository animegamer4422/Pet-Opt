import 'package:flutter/material.dart';
import '../../data/post_store.dart';
import '../../models/post.dart';

enum AccountType { individual, organization }
enum PrimaryIntent { adopt, post }

String accountTypeLabel(AccountType v) =>
    v == AccountType.individual ? 'Individual' : 'Organization';

String intentLabel(PrimaryIntent v) =>
    v == PrimaryIntent.adopt ? 'Adopt a pet' : 'Post for adoption';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PostStore.instance;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Demo user (for now)
    const currentUserName = "Hari";
    const accountType = AccountType.individual;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final posts = store.posts;

          final myPosts =
              posts.where((p) => p.authorName == currentUserName).toList();

          final savedPosts = posts.where((p) => p.saved).toList();

          final totalLikesReceived =
              myPosts.fold<int>(0, (sum, p) => sum + p.likeCount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeaderCard(
                  name: currentUserName,
                  accountType: accountType,
                ),
                const SizedBox(height: 16),

                /// Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatPill(label: "Posts", value: myPosts.length),
                    _StatPill(label: "Saved", value: savedPosts.length),
                    _StatPill(label: "Likes", value: totalLikesReceived),
                  ],
                ),

                const SizedBox(height: 24),

                /// My Posts Section
                Text("My Posts",
                    style: t.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                myPosts.isEmpty
                    ? _EmptyState(
                        message:
                            "You haven't posted anything yet.\nCreate your first adoption post.")
                    : Column(
                        children: myPosts
                            .map((p) => _MiniPostCard(post: p))
                            .toList(),
                      ),

                const SizedBox(height: 24),

                /// Saved Section
                Text("Saved Posts",
                    style: t.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                savedPosts.isEmpty
                    ? _EmptyState(
                        message:
                            "You haven't saved any posts yet.")
                    : Column(
                        children: savedPosts
                            .map((p) => _MiniPostCard(post: p))
                            .toList(),
                      ),

                const SizedBox(height: 32),

                Divider(color: cs.outlineVariant),

                const SizedBox(height: 12),

                Text(
                  "Demo Mode",
                  style: t.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final AccountType accountType;

  const _ProfileHeaderCard({
    required this.name,
    required this.accountType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: cs.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: t.headlineMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: t.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    accountTypeLabel(accountType),
                    style: t.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;

  const _StatPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style:
                t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: t.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPostCard extends StatelessWidget {
  final Post post;

  const _MiniPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
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
            child: Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: t.bodyMedium?.copyWith(
          color: cs.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}
