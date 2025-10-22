import 'dart:developer';

import 'package:tracks/components/chat_bubble.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pocketbase/pocketbase.dart';

enum MessageType { text, loading, clickable }

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
  late RecordModel _userClaim;

  final _pb = PocketBaseService.instance;

  String _pageTitle = 'New Claim';
  bool _isLoading = true;
  String? _error;
  
  // Track processing stages
  final List<String> _completedStages = [];
  String _currentStage = '';
  String _currentMessage = 'Processing...';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scm = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        _userClaim = widget.userClaim;

        _pb.client.realtime.subscribe(
          'process-${_userClaim.getStringValue('id')}',
          (e) async {
            final data = e.jsonData();

            try {
              
              _handleProcessNotify(data);

            } on Exception catch (e) {  
              scm.showSnackBar(
                SnackBar(
                  duration: snackBarShort,
                  content: Text(errorFatal(e)),
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
            }

            if (context.mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        );
      } on Exception catch (e) {
        scm.showSnackBar(
          SnackBar(
            duration: snackBarShort,
            content: Text(errorFatal(e)),
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
      }
    });

    image = widget.userClaimImage;
    super.initState();
  }

  @override
  void dispose() {
    _pb.client.realtime.unsubscribe(
      'process-${_userClaim.getStringValue('id')}',
    );
    super.dispose();
  }

  void _handleProcessNotify(data) async {
    final bool status = data['status'] ?? false;
    final String message = data['message'] ?? '';
    final String stage = data['stage'] ?? '';

    log("Process notification - Stage: $stage, Status: $status, Message: $message");

    // Handle error case
    if (!status) {
      setState(() {
        _error = message;
        _isLoading = false;
        _currentStage = stage;
        _currentMessage = message;
      });
      throw Exception("Processing failed at stage '$stage': $message");
    }

    // Handle success case - update stage tracking
    setState(() {
      _currentStage = stage;
      _currentMessage = message;
      
      // Add stage to completed stages if not already there
      if (!_completedStages.contains(stage)) {
        _completedStages.add(stage);
      }
    });

    // Refresh claim data from server
    try {
      _userClaim = await _pb.client
          .collection('claims')
          .getOne(_userClaim.id, expand: 'claim_evidence(claim)');

      log('Fetched claim data with expand. Expand keys: ${_userClaim.expand.keys}');

      // Update title if available
      final title = _userClaim.getStringValue('title');
      if (title.isNotEmpty) {
        setState(() {
          _pageTitle = title;
        });
      }

      // Check if all stages are complete
      if (stage == 'Final' || _completedStages.length >= 3) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      log("Error refreshing claim data: $e");
      // Don't throw here, just log - we still got the notification
    }
  }

  List<Widget> getResponses() {
    final List<Message> messages = [];

    // If there's an error, display it
    if (_error != null) {
      messages.add(
        Message(
          type: MessageType.text,
          icon: Icons.error_outline,
          body: 'Processing failed: $_error',
        ),
      );
      return _buildMessageWidgets(messages);
    }

    // Show stage progress while loading
    if (_isLoading) {
      // Context stage
      if (_completedStages.contains('Context')) {
        messages.add(
          Message(
            type: MessageType.text,
            icon: Icons.check_circle_outline,
            body: 'Context analysis complete',
          ),
        );
      } else if (_currentStage == 'Context') {
        messages.add(
          Message(
            type: MessageType.loading,
            body: _currentMessage,
          ),
        );
      }

      // Search stage
      if (_completedStages.contains('Search')) {
        messages.add(
          Message(
            type: MessageType.text,
            icon: Icons.check_circle_outline,
            body: 'Evidence search complete',
          ),
        );
      } else if (_currentStage == 'Search') {
        messages.add(
          Message(
            type: MessageType.loading,
            body: _currentMessage,
          ),
        );
      }

      // Final stage
      if (_completedStages.contains('Final')) {
        messages.add(
          Message(
            type: MessageType.text,
            icon: Icons.check_circle_outline,
            body: 'Final analysis complete',
          ),
        );
      } else if (_currentStage == 'Final') {
        messages.add(
          Message(
            type: MessageType.loading,
            body: _currentMessage,
          ),
        );
      }

      // If no stage started yet
      if (_currentStage.isEmpty) {
        messages.add(
          Message(
            type: MessageType.loading,
            body: 'Starting analysis...',
          ),
        );
      }

      return _buildMessageWidgets(messages);
    }

    // Processing complete - show final results
    final searchTerm = _userClaim.getStringValue('search_term');
    String verdict = _userClaim.getStringValue('verdict');
    
    log('=== PROCESSING COMPLETE ===');
    log('searchTerm: "$searchTerm"');
    log('verdict from claim: "$verdict"');
    
    // Get the description from claim_evidence
    final claimEvidenceList = _userClaim.expand['claim_evidence(claim)'];
    log('claimEvidenceList: $claimEvidenceList');
    log('claimEvidenceList is null: ${claimEvidenceList == null}');
    log('claimEvidenceList isEmpty: ${claimEvidenceList?.isEmpty ?? true}');
    
    String? description;
    if (claimEvidenceList != null && claimEvidenceList.isNotEmpty) {
      description = claimEvidenceList.first.getStringValue('description');
      log('description: "$description"');
      
      // If verdict is empty on the claim, try to get it from claim_evidence
      if (verdict.isEmpty) {
        verdict = claimEvidenceList.first.getStringValue('verdict');
        log('verdict from claim_evidence: "$verdict"');
      }
    }
    
    log('Final verdict to use: "$verdict"');
    log('verdict.isNotEmpty: ${verdict.isNotEmpty}');

    messages.add(
      Message(
        type: MessageType.text,
        icon: Icons.check_circle,
        body: 'Analysis complete! Here are the results:',
      ),
    );

    if (searchTerm.isNotEmpty) {
      log('Adding search term message');
      messages.add(
        Message(
          type: MessageType.text,
          icon: Icons.search,
          body: 'Search term: "$searchTerm"',
        ),
      );
    }

    if (verdict.isNotEmpty) {
      log('Verdict is not empty, adding verdict messages');
      IconData verdictIcon;
      switch (verdict) {
        case 'true':
          verdictIcon = Icons.check_circle;
          break;
        case 'false':
          verdictIcon = Icons.cancel;
          break;
        case 'likely-true':
          verdictIcon = Icons.check_circle_outline;
          break;
        case 'likely-false':
          verdictIcon = Icons.cancel_outlined;
          break;
        default:
          verdictIcon = Icons.help_outline;
      }

      messages.add(
        Message(
          type: MessageType.text,
          icon: verdictIcon,
          body: 'Verdict: ${verdict.replaceAll('-', ' ').toUpperCase()}',
        ),
      );
      
      // Add fun verdict message
      final funMessage = 'This shit is ${verdict.replaceAll('-', ' ')} as hell';
      log('Adding fun message: "$funMessage"');
      messages.add(
        Message(
          type: MessageType.text,
          body: funMessage,
        ),
      );
    } else {
      log('Verdict is EMPTY - not adding verdict messages');
    }

    if (description != null && description.isNotEmpty) {
      log('Adding description message');
      messages.add(
        Message(
          type: MessageType.text,
          body: description,
        ),
      );
    }
    
    log('Total messages created: ${messages.length}');
    for (var i = 0; i < messages.length; i++) {
      log('Message $i: "${messages[i].body}"');
    }

    return _buildMessageWidgets(messages);
  }

  List<Widget> _buildMessageWidgets(List<Message> messages) {
    final List<Widget> widgets = [];

    for (var msg in messages) {
      if (msg.body.isEmpty || msg.body == "") continue;
      widgets.addAll([
        ChatBubble(
          onTap: msg.onClick,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.icon != null || msg.type == MessageType.loading) ...[
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: (msg.type == MessageType.loading)
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(msg.icon, size: 16),
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
                      _pageTitle,
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

                    Column(
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
