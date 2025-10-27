import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/secondary_button.dart';

class ModalOptions extends StatefulWidget {
  const ModalOptions({super.key});

  @override
  State<ModalOptions> createState() => _ModalOptionsState();
}

enum AnimationSetting { generic, helpful }

class _ModalOptionsState extends State<ModalOptions> {
  AnimationSetting? _selectedAnimation = AnimationSetting.generic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),

          Text(
            "Animation",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          RadioGroup(
            groupValue: _selectedAnimation,
            onChanged: (value) {
              setState(() {
                _selectedAnimation = value;
              });
            },
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...AnimationSetting.values.map((setting) {
                  return Pressable(
                    onTap: () {
                      setState(() {
                        _selectedAnimation = setting;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.grey[200]!,
                            offset: const Offset(0, -1),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset(
                                  setting.name == 'generic'
                                      ? 'assets/drawings/cat-svgrepo-com.svg'
                                      : 'assets/drawings/undraw_ai-answers_uxgx.svg',
                                  width: 64,
                                ),
                                Transform.scale(
                                  scale: 1.5,
                                  child: Radio<AnimationSetting>(
                                    value: setting,
                                  ),
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  setting.name[0].toUpperCase() +
                                      setting.name.substring(1),
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  setting.name == 'generic'
                                      ? "To fill up the screen"
                                      : "For certain exercise",
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              child: Row(
                children: [
                  Icon(MingCute.sad_line, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "Give Up",
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
    );
  }
}
