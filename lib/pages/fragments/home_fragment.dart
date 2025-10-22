import 'package:tracks/pages/claim_page.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final ImagePicker _picker = ImagePicker();

  final _pb = PocketBaseService.instance;
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<RecordModel?> createClaim(XFile image) async {
    try {
      final imageBytes = await image.readAsBytes();

      return await _pb.client
          .collection('claims')
          .create(
            body: {'user': _pb.authStore.record?.id},
            files: [
              http.MultipartFile.fromBytes(
                'source_image',
                imageBytes,
                filename: image.name,
              ),
            ],
          );
    } on ClientException {
      rethrow;
    }
  }

  Future<void> handleCreateClaimUrl() async {}

  void _handleCreateFromUrl(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enter an article, news, or something:'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'https://somenews.com/somefakenews',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                        ),
                        onFieldSubmitted: (value) => handleCreateClaimUrl(),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a URL";
                          }
                          try {
                            final uri = Uri.parse(value);
                            if (!uri.isAbsolute ||
                                !['http', 'https'].contains(uri.scheme)) {
                              return "Please enter a valid http/https URL";
                            }
                          } catch (e) {
                            return "Please enter a valid URL";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isLoading) ...[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _isLoading = false;
                                  _textController.text = "";
                                });
                              },
                              child: Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          FilledButton.tonal(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      setModalState(() {
                                        _isLoading = true;
                                      });
                                      await handleCreateClaimUrl();
                                    }
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Go'),
                                const SizedBox(width: 8),
                                (_isLoading)
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final firstName = user?['name'].toString().split(' ')[0] ?? '';

    final quickAccess = [
      {
        'icon': Iconsax.image_outline,
        'subtitle': 'Check from',
        'title': 'Image',
        'action': (context) async {
          final scm = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          try {
            final XFile? picture = await _picker.pickImage(
              source: ImageSource.gallery,
            );

            if (picture != null) {
              scm.showSnackBar(
                SnackBar(
                  duration: snackBarShort,
                  content: Text("Creating new claim..."),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                ),
              );

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
                content: Text(e.toString()),
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
        'action': (context) async {
          final scm = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          try {
            final XFile? picture = await _picker.pickImage(
              source: ImageSource.camera,
            );

            if (picture != null) {
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
        'icon': Iconsax.link_21_outline,
        'subtitle': 'Check web page',
        'title': 'URL',
        'action': (context) => _handleCreateFromUrl(context),
      },
      {
        'icon': Iconsax.search_normal_outline,
        'subtitle': 'Search',
        'title': 'Fact Checks',
        'action': (context) {},
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
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

            const SizedBox(height: 32),

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

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            onTap: () => item['action'] != null
                                ? (item['action'] as Function)(context)
                                : null,
                            borderRadius: BorderRadius.circular(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
      ),
    );
  }
}
