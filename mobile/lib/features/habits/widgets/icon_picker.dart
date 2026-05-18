import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

const String kDefaultHabitIcon = 'assets/icons/habits/star.svg';

const List<String> kHabitIcons = [
  'assets/icons/habits/star.svg',
  'assets/icons/habits/flame.svg',
  'assets/icons/habits/heart.svg',
  'assets/icons/habits/droplet.svg',
  'assets/icons/habits/sun.svg',
  'assets/icons/habits/moon.svg',
  'assets/icons/habits/leaf.svg',
  'assets/icons/habits/book.svg',
  'assets/icons/habits/dumbbell.svg',
  'assets/icons/habits/trophy.svg',
  'assets/icons/habits/clock.svg',
  'assets/icons/habits/bolt.svg',
  'assets/icons/habits/pencil.svg',
  'assets/icons/habits/music.svg',
  'assets/icons/habits/target.svg',
  'assets/icons/habits/coffee.svg',
  'assets/icons/habits/check-circle.svg',
  'assets/icons/habits/footsteps.svg',
  'assets/icons/habits/meditation.svg',
  'assets/icons/habits/wind.svg',
];

/// Renders the current habit icon as an interactive tap target.
/// Tapping opens a bottom-sheet grid to pick a new icon.
class HabitIconPicker extends StatelessWidget {
  const HabitIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.size = 56.0,
    this.backgroundColor,
    this.iconColor,
  });

  final String selectedIcon;
  final ValueChanged<String> onIconSelected;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  Future<void> _showPicker(BuildContext context) async {
    final mc = context.mc;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: mc.bgCanvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _IconPickerSheet(
        selectedIcon: selectedIcon,
        onIconSelected: (icon) {
          Navigator.of(ctx).pop();
          onIconSelected(icon);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final bg = backgroundColor ?? mc.hairline;
    final color = iconColor ?? mc.inkPrimary;

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size * 0.214),
          border: Border.all(
            color: mc.hairlineStrong.withAlpha(80),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: _HabitSvgIcon(
                path: selectedIcon,
                size: size * 0.54,
                color: color,
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Icon(
                Icons.edit_rounded,
                size: 10,
                color: mc.inkTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPickerSheet extends StatelessWidget {
  const _IconPickerSheet({
    required this.selectedIcon,
    required this.onIconSelected,
  });

  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: mc.hairlineStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose an icon',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: mc.inkPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: kHabitIcons.map((path) {
              final isSelected = path == selectedIcon;
              return _IconCell(
                path: path,
                isSelected: isSelected,
                onTap: () => onIconSelected(path),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.path,
    required this.isSelected,
    required this.onTap,
  });

  final String path;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    const accent = Color(0xFF6C63FF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? accent : mc.hairline,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _HabitSvgIcon(
            path: path,
            size: 26,
            color: isSelected ? Colors.white : mc.inkPrimary,
          ),
        ),
      ),
    );
  }
}

/// Renders a habit SVG icon, falling back to a generic icon for non-SVG paths.
class _HabitSvgIcon extends StatelessWidget {
  const _HabitSvgIcon({
    required this.path,
    required this.size,
    required this.color,
  });

  final String path;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    // Backward compat: emoji or plain text icon
    return Text(path, style: TextStyle(fontSize: size * 0.8));
  }
}

/// Public SVG icon widget used outside the picker (habit card, detail screen).
class HabitSvgIcon extends StatelessWidget {
  const HabitSvgIcon({
    super.key,
    required this.path,
    required this.size,
    required this.color,
  });

  final String path;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Text(path, style: TextStyle(fontSize: size * 0.8));
  }
}
