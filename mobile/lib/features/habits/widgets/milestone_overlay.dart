import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class MilestoneOverlay extends StatelessWidget {
  final String habitName;
  final String? habitIcon;
  final int milestoneValue;
  final String? habitColor;

  const MilestoneOverlay({
    super.key,
    required this.habitName,
    this.habitIcon,
    required this.milestoneValue,
    this.habitColor,
  });

  String get _headline {
    if (milestoneValue >= 365) return 'A full year.';
    if (milestoneValue >= 100) return '$milestoneValue days.';
    if (milestoneValue >= 30) return 'One month in.';
    return 'One week done.';
  }

  String get _message {
    if (milestoneValue >= 365) {
      return 'You showed up for $habitName 365 times. That\'s not a streak — that\'s who you are now.';
    }
    if (milestoneValue >= 100) {
      return 'A hundred check-ins for $habitName. Most people quit at day three.';
    }
    if (milestoneValue >= 30) {
      return 'Thirty days of $habitName. You\'ve shown up more than you think.';
    }
    return 'Seven days of $habitName. The first week is the hardest. You did it.';
  }

  @override
  Widget build(BuildContext context) {
    final accent = MomentumPigments.fromHex(habitColor);
    final darkAccent = Color.lerp(accent, Colors.black, 0.30)!;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [accent, darkAccent],
              radius: 1.4,
              center: Alignment.topLeft,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // "Day N" watermark
                Positioned(
                  bottom: 60,
                  right: -10,
                  child: Text(
                    'Day\n$milestoneValue',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.fraunces(
                      fontSize: 88,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(18),
                      letterSpacing: -2,
                      height: 0.9,
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji halo (132×132)
                        Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(30),
                          ),
                          child: Center(
                            child: Text(
                              habitIcon != null && habitIcon!.isNotEmpty
                                  ? habitIcon!
                                  : '✨',
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          _headline,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fraunces(
                            fontSize: 44,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: -1.2,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fraunces(
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withAlpha(210),
                            height: 1.55,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 56),
                        Text(
                          'Tap anywhere to continue',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
