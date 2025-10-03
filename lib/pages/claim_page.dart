import 'package:factual/components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ClaimPage extends StatefulWidget {
  final XFile initImage;

  const ClaimPage({super.key, required this.initImage});

  @override
  State<ClaimPage> createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  late XFile image;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    image = widget.initImage;
  }

  /**
   * @TODO
   * 1. request claims from backend
   * 2. show resulted option
   * 3. if option = 1, run the synthesize right away
   * 4. show the result
   */

  final optionsWidget = [
    ChatBubble(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(Icons.question_mark_outlined, size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Found more than 1 items that can be checked, please select item to fact check.',
            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 8),

    ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: ChatBubble(
              onTap: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.arrow_circle_right_outlined, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Lorem ipsum dolor sit amet.')),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(),
                    Text(
                      'New Claim',
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ChatBubble(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 256,
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _isLoading
                        ? Container(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ChatBubble(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Processing...'),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
