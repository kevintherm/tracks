import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tracks/components/buttons/primary_button.dart';

class SessionFinishPage extends StatefulWidget {
  const SessionFinishPage({super.key});

  @override
  State<SessionFinishPage> createState() => _SessionFinishPageState();
}

class _SessionFinishPageState extends State<SessionFinishPage>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool _showContent = false;

  void _handleFinishButton() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showContent = true;
        });

        _lottieController.stop();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Center(
                child: _showContent
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SvgPicture.asset(
                            'assets/drawings/undraw_well-done_kqud.svg',
                            height: 350,
                          ),
                        ),
                      )
                    : Lottie.asset(
                        'assets/animations/session-complete.json',
                        height: 350,
                        controller: _lottieController,
                        repeat: false,
                        onLoaded: (composition) {
                          _lottieController
                            ..duration = composition.duration * 0.667
                            ..forward();
                        },
                      ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _showContent
                      ? Column(
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              'Great Job!',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You completed your session',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onTap: !_showContent ? null : _handleFinishButton,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(MingCute.right_line, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Finish",
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
      ),
    );
  }
}
