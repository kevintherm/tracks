import 'package:pocketbase/pocketbase.dart';

class Post {
  String id;
  String userId;
  String title;
  String slug;
  String content;
  List<String> files;
  DateTime created;
  DateTime updated;

  // Expanded fields
  String? userName;
  String? userAvatar;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.slug,
    required this.content,
    required this.files,
    required this.created,
    required this.updated,
    this.userName,
    this.userAvatar,
  });

  factory Post.fromRecord(RecordModel record) {
    final expand = record.expand;
    String? userName;
    String? userAvatar;

    if (expand.containsKey('user') && expand['user'] != null) {
      final userRecord = expand['user']!.first;
      userName = userRecord.getStringValue('name');
      userAvatar = userRecord.getStringValue('avatar');
    }

    return Post(
      id: record.id,
      userId: record.getStringValue('user'),
      title: record.getStringValue('title'),
      slug: record.getStringValue('slug'),
      content: record.getStringValue('content'),
      files: record.getListValue<String>('files'),
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
      userName: userName,
      userAvatar: userAvatar,
    );
  }
}
