import 'dart:developer';

import 'package:factual/components/chat_bubble.dart';
import 'package:factual/services/pocketbase_service.dart';
import 'package:factual/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pocketbase/pocketbase.dart';

enum MessageType { text, clickable }

class Message {
  final MessageType type;
  final String body;
  final dynamic icon;
  final void Function()? onClick;

  Message({required this.type, required this.body, this.onClick, this.icon});

  @override
  String toString() => 'Message(type: $type, body: $body)';
}

class ClaimPage extends StatefulWidget {
  final RecordModel userClaim;
  final XFile userClaimImage;

  const ClaimPage({
    super.key,
    required this.userClaim,
    required this.userClaimImage,
  });

  @override
  State<ClaimPage> createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  late XFile image;
  late RecordModel userClaim;

  final pb = PocketBaseService.instance;
  
  bool _isLoading = true;

  @override
  void initState() {
    userClaim = widget.userClaim;
    WidgetsBinding.instance.addPostFrameCallback((_) {

      // log('process-${userClaim}');

      pb.client.realtime.subscribe('process-${userClaim.getStringValue('id')}', (e) {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        final scm = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        final data = e.jsonData();

        if (!data['status']) {
          scm.showSnackBar(
            SnackBar(
              duration: snackBarShort,
              content: Text('Failed to create a new claim.'),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
            ),
          );

          navigator.pop();
          return;
        }
      });
    });

    image = widget.userClaimImage;
    super.initState();
  }

  @override
  void dispose() {
    pb.client.realtime.unsubscribe('process-${userClaim.getStringValue('id')}');
    super.dispose();
  }

  List<Widget> getResponses() {
    final List<Message> messages = [];

    // final imageDesc = userClaim['image_description'];
    final extractedTexts = userClaim.getListValue<String>('extracted_texts');
    final hasSignOfAltered = userClaim.getBoolValue('has_sign_of_altered');
    final hasSignOfAiGenerated = userClaim.getBoolValue('has_sign_of_ai_generated');
    final reason = userClaim.getStringValue('reason');

    // messages.add(Message(body: imageDesc, type: MessageType.text));

    if (extractedTexts.length > 1) {
      messages.add(
        Message(
          type: MessageType.text,
          icon: Icons.error_outline,
          body:
              "More than 1 text were found, please select which one to check.",
        ),
      );

      for (var text in extractedTexts) {
        messages.add(
          Message(
            type: MessageType.clickable,
            icon: Icons.arrow_circle_right_outlined,
            body: text,
            onClick: () {
              // implement click to send event to server
            },
          ),
        );
      }
    } else if (extractedTexts.length == 1) {
      messages.add(
        Message(
          type: MessageType.text,
          icon: Icons.question_mark_outlined,
          body: "Is this the topic you'd like to check?",
        ),
      );

      messages.add(Message(type: MessageType.text, body: extractedTexts[0]));

      for (var text in ["Yes", "No"]) {
        messages.add(
          Message(
            type: MessageType.clickable,
            icon: Icons.arrow_circle_right_outlined,
            body: text,
            onClick: () {
              // implement click to send event to server
            },
          ),
        );
      }
    } else {
      // No text were found
      messages.add(
        Message(
          type: MessageType.text,
          body: "The image did not contains any text.",
        ),
      );

      final buffer = StringBuffer('Looks like this image ');

      if (hasSignOfAiGenerated) {
        buffer.write('shows signs of AI-generated content.');
      } else if (hasSignOfAltered) {
        buffer.write('seems to have been digitally altered.');
      } else {
        buffer.write('doesn’t show any signs of AI generation or editing.');
      }

      final message = MessageType.text;
      final body = buffer.toString();

      messages.add(Message(type: message, body: body));
      messages.add(Message(type: MessageType.text, body: reason));
    }

    final List<Widget> widgets = [];

    log(messages.toString());

    for (var msg in messages) {
      if (msg.body == "") continue;
      widgets.addAll([
        ChatBubble(
          onTap: msg.onClick,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.type != MessageType.text) ...[
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(msg.icon, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  msg.body,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ]);
    }

    return widgets;
  }

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
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: getResponses(),
                          ),
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
