enum MediaType { image, video }

class MediaItem {
  final MediaType type;
  final String path; // local file path for now
  const MediaItem({required this.type, required this.path});
}

class Post {
  final String id;
  final String title;
  final List<MediaItem> media;

  const Post({
    required this.id,
    required this.title,
    required this.media,
  });
}
