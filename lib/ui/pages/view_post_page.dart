import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/post.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/utils/app_colors.dart';

class ViewPostPage extends StatelessWidget {
  final Post post;

  const ViewPostPage({super.key, required this.post});

  String get _userAvatar {
    return PocketBaseService.instance.client.files
        .getURL(
          RecordModel({'collectionName': 'users', 'id': post.userId}),
          post.userAvatar ?? '',
        )
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Pressable(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Iconsax.arrow_left_2_outline, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    post.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                post.title,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    foregroundImage: post.userAvatar != null ? CachedNetworkImageProvider(_userAvatar) : null,
                    child: post.userAvatar != null ? null : Text("T", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName ?? 'Unknown Author',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        post.created.toString().split(' ')[0],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Html(
                data: post.content,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
