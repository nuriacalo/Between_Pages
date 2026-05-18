// Defines the type of media
enum MediaType { book, manga, fanfic }

// An abstract class that all media types will implement.
// This ensures that every item in a list has the core properties needed for display.
abstract class MediaItem {
  String get title;
  String get author;
  String? get coverImageUrl;
  MediaType get itemType;
}
