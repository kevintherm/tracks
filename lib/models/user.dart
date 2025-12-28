import 'dart:developer';

import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/utils/consts.dart';

// Pocketbase Representation of User collection
class User {
  String id;

  String username;

  String email;

  String name;

  String bio;

  String? avatar;

  bool emailVisibility = false;

  bool verified = false;

  int followers = 0;

  int followings = 0;

  int totalViews = 0;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  Map<String, List<RecordModel>> expand;

  User({
    required this.id,
    this.username = '',
    this.email = '',
    this.name = '',
    this.bio = '',
    this.avatar,
    this.emailVisibility = false,
    this.verified = false,
    this.followers = 0,
    this.followings = 0,
    this.totalViews = 0,
    this.expand = const {}
  });

  static Future<User?> fetchUserById(id, {String expand = ''}) async {
    final pb = PocketBaseService.instance.client;

    try {
      final record = await pb.collection(PBCollections.users.value).getOne(id, expand: expand);
      return User.fromRecord(record);
    } on ClientException catch (e) {
      log('[Error] $e');
      if (e.statusCode == 404) {
        return null;
      } else {
        rethrow;
      }
    } catch (e) {
      log('[Error] $e');
      rethrow;
    }

  }

  static User fromRecord(RecordModel record) {
    final pb = PocketBaseService.instance.client;
    final user = User(
      id: record.id,
      username: record.data['username'] ?? '',
      email: record.data['email'] ?? '',
      name: record.data['name'] ?? '',
      bio: record.data['bio'] ?? '',
      emailVisibility: record.data['emailVisibility'] ?? false,
      verified: record.data['verified'] ?? false,
      followers: record.data['followers'] ?? 0,
      followings: record.data['followings'] ?? 0,
      totalViews: record.data['total_copies'] ?? 0,
      avatar: record.data['avatar'],
      // ignore: deprecated_member_use
      expand: record.expand,
    );

    user.createdAt =
        DateTime.tryParse(record.data['created']) ?? DateTime.now();
    user.updatedAt =
        DateTime.tryParse(record.data['updated']) ?? DateTime.now();

    final avatarField = record.data['avatar'];
    if (avatarField != null && avatarField.toString().isNotEmpty) {
      user.avatar = pb.files.getURL(record, user.avatar ?? '').toString();
    }

    return user;
  }

  Map<String, dynamic> toPayload() {
    return {
      'username': username,
      'email': email,
      'name': name,
      'bio': bio,
      'emailVisibility': emailVisibility,
      'followers': followers,
      'followings': followings,
      'total_views': totalViews,
    };
  }

  void updateFrom(User other) {
    username = other.username;
    email = other.email;
    name = other.name;
    avatar = other.avatar;
    bio = other.bio;
    emailVisibility = other.emailVisibility;
    verified = other.verified;
    followers = other.followers;
    followings = other.followings;
    totalViews = other.totalViews;
    updatedAt = other.updatedAt;
  }
}
