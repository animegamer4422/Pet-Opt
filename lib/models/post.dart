enum MediaType { image, video }

class MediaItem {
  final MediaType type;
  final String path; // local file path or asset path for now
  const MediaItem({required this.type, required this.path});
}

class Post {
  final String id;
  final String title;
  final List<MediaItem> media;

  final String authorName;
  final DateTime createdAt;

  bool liked;
  bool saved;
  int likeCount;
  int commentCount;

  Post({
    required this.id,
    required this.title,
    required this.media,
    required this.authorName,
    required this.createdAt,
    this.liked = false,
    this.saved = false,
    this.likeCount = 0,
    this.commentCount = 0,
  });
}
