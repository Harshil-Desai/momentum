import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/daily_log_provider.dart';
import '../../../core/theme/app_theme.dart';

class EnergyRatingSheet extends ConsumerStatefulWidget {
  const EnergyRatingSheet({super.key});

  @override
  ConsumerState<EnergyRatingSheet> createState() => _EnergyRatingSheetState();
}

class _EnergyRatingSheetState extends ConsumerState<EnergyRatingSheet> {
  int? _selected;

  static const _labels = ['Drained', 'Low', 'Okay', 'Good', 'Energized'];
  static const _emojis = ['😴', '😐', '🙂', '😊', '⚡'];

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final iris = MomentumPigments.iris;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: mc.hairlineStrong,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How is today landing?',
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: mc.inkPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional — helps you spot patterns over time.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: mc.inkTertiary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(5, (i) {
              final level = i + 1;
              final isSelected = _selected == level;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 72,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? iris.withAlpha(25) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? iris : mc.hairlineStrong,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_emojis[i],
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            _labels[i],
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: isSelected ? iris : mc.inkTertiary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {
                ref.read(dailyLogProvider.notifier).markSkipped();
                Navigator.of(context).pop();
              },
              child: Text(
                'Skip for now',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: mc.inkTertiary,
                  letterSpacing: -0.05,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selected == null
                ? null
                : () async {
                    await ref
                        .read(dailyLogProvider.notifier)
                        .submit(energy: _selected);
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 56,
              decoration: BoxDecoration(
                color: _selected == null
                    ? mc.inkPrimary.withAlpha(80)
                    : mc.inkPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'Save the note',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: mc.bgCanvas,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
