import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/post.dart';

class PostRepository {
  final PocketBase pb;

  PostRepository(this.pb);

  Future<List<Post>> getPosts() async {
    final records = await pb.collection('posts').getFullList(
      sort: '-created',
      expand: 'user',
    );
    return records.map((record) => Post.fromRecord(record)).toList();
  }

  Uri getFileUrl(Post post, String filename) {
    return pb.files.getUrl(
      RecordModel({'collectionName': 'posts', 'id': post.id}),
      filename,
    );
  }
}

