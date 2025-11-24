import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/safe_keyboard.dart';
import 'package:tracks/ui/pages/modals/session_finish_failure_dialog.dart';
import 'package:tracks/ui/pages/modals/session_finish_note_dialog.dart';
import 'package:tracks/ui/pages/modals/session_finish_rate_fail_dialog.dart';
import 'package:tracks/ui/pages/modals/session_options.dart';
import 'package:tracks/ui/pages/modals/session_finish_reps_dialog.dart';
import 'package:tracks/ui/pages/session_finish_page.dart';
import 'package:tracks/utils/app_colors.dart';

class SessionPage extends StatefulWidget {
  
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final bool _isLoading = false;
  final double _progress = 10;

  void _handleNextButton() async {
    final nav = Navigator.of(context);

    int? currentReps = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return _ModalPadding(child: SessionFinishRepsDialog());
      },
    );

    if (currentReps == null) return;

    if (mounted) {
      int failOnRep = await showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (BuildContext context) {
          return _ModalPadding(child: SessionFinishFailureDialog());
        },
      );
    }

    if (mounted) {
      final failRate = await showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (BuildContext context) {
          return _ModalPadding(child: SessionFinishRateFailDialog());
        },
      );
    }

    if (mounted) {
      String? note = await showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (BuildContext context) {
          return _ModalPadding(child: SessionFinishNoteDialog());
        },
      );
    }

    nav.pushReplacement(
      MaterialPageRoute(builder: (context) => SessionFinishPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Pressable(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            builder: (context) => ModalOptions(),
                          );
                        },
                        child: Icon(MingCute.settings_3_line, size: 32),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 20,
                            disabledActiveTrackColor: AppColors.lightPrimary,
                            thumbShape: SliderComponentShape.noThumb,
                          ),
                          child: Slider(
                            value: _progress,
                            min: 0,
                            max: 100,
                            onChanged: null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current exercise:",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[600]
                              : Colors.grey[300],
                        ),
                      ),
                      Text(
                        "Push Up",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: SafeKeyboard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 300,
                              child: Lottie.asset(
                                'assets/animations/idle-people.json',
                                animate: true,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Set 1",
                              style: GoogleFonts.spaceMono(fontSize: 16),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "03:00",
                              style: GoogleFonts.spaceMono(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onTap: _isLoading ? null : _handleNextButton,
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(MingCute.right_line, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  "Finish Set",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _ModalPadding extends StatelessWidget {
  final Widget child;

  const _ModalPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16, top: 24),
      child: child,
    );
  }
}
