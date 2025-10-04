import 'package:factual/pages/claim_page.dart';
import 'package:factual/services/auth_service.dart';
import 'package:factual/services/pocketbase_service.dart';
import 'package:factual/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeFragment extends StatelessWidget {
  HomeFragment({super.key});

  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final firstName = user?['name'].toString().split(' ')[0] ?? '';

    final pb = PocketBaseService.instance;

    Future<RecordModel?> createClaim(XFile image) async {
      try {
        final imageBytes = await image.readAsBytes();

        return await pb.client
            .collection('claims')
            .create(
              body: {'users': pb.authStore.record?.id},
              files: [
                http.MultipartFile.fromBytes(
                  'input_image',
                  imageBytes,
                  filename: image.name,
                ),
              ],
            );
      } on ClientException {
        rethrow;
      }
    }

    final quickAccess = [
      {
        'icon': Iconsax.image_outline,
        'subtitle': 'Check from',
        'title': 'Image',
        'action': (context) async {
          final scm = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          try {
            final XFile? picture = await picker.pickImage(
              source: ImageSource.gallery,
            );

            if (picture != null) {
              // scm.showSnackBar(
              //   SnackBar(
              //     duration: snackBarShort,
              //     content: Text('Creating claim...'),
              //     backgroundColor: Colors.grey[600],
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.only(
              //         topLeft: Radius.circular(8.0),
              //         topRight: Radius.circular(8.0),
              //       ),
              //     ),
              //   ),
              // );

              final userClaim = await createClaim(picture);
              if (userClaim != null) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => ClaimPage(
                      userClaimImage: picture,
                      userClaim: userClaim,
                    ),
                  ),
                );
              } else {
                throw Exception("Failed creating claim.");
              }
            }
          } catch (e) {
            scm.showSnackBar(
              SnackBar(
                duration: snackBarShort,
                content: Text(fatalError),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
              ),
            );
          }
        },
      },
      {
        'icon': Iconsax.camera_outline,
        'subtitle': 'Check from',
        'title': 'Camera',
        'action': (context) {},
      },
      {
        'icon': Iconsax.link_21_outline,
        'subtitle': 'Check web page',
        'title': 'URL',
        'action': (context) {},
      },
      {
        'icon': Iconsax.search_normal_outline,
        'subtitle': 'Search',
        'title': 'Fact Checks',
        'action': (context) {},
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Iconsax.message_2_outline),
                  iconSize: 32,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Iconsax.notification_1_outline),
                  iconSize: 32,
                ),
              ],
            ),
          ),

          Spacer(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/solar_icons/smile-circle.svg',
                  width: 64,
                  height: 64,
                ),

                const SizedBox(height: 8),

                Text(
                  'Hello, $firstName!',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[700],
                  ),
                ),

                Text(
                  'What kind of shitpost are we checking today?',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: quickAccess.length,
                  itemBuilder: (context, index) {
                    final item = quickAccess[index];

                    return Card(
                      child: InkWell(
                        onTap: () => item['action'] != null
                            ? (item['action'] as Function)(context)
                            : null,
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                item['icon'] as IconData?,
                                size: 32,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 32),
                              Text(
                                item['subtitle'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey[600]
                                      : Colors.grey[300],
                                ),
                              ),
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
