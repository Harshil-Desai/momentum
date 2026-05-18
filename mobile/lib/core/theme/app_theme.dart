import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Momentum color tokens ────────────────────────────────────────────────────
//
//  Light (Frozen Water canvas):
//    bgCanvas     #DCECEB   Frozen Water, desaturated
//    surface      #FFFFFF
//    inkPrimary   #0D0221   Midnight Violet
//    inkSecondary #26408B   French Blue
//    inkTertiary  #7A96B0   derived
//    hairline     rgba(13,2,33, 0.10)
//    hairlineStrong rgba(13,2,33, 0.22)
//    scrim        rgba(13,2,33, 0.40)
//
//  Dark (Midnight canvas):
//    bgCanvas     #0D0221
//    surface      #170A3C
//    inkPrimary   #C2E7D9   Frozen Water
//    inkSecondary #A6CFD5   Light Blue
//    inkTertiary  #6A7E92
//    hairline     rgba(194,231,217, 0.10)
//    hairlineStrong rgba(194,231,217, 0.22)
//    scrim        rgba(0,0,0, 0.60)
//
//  Six pigments (twilight tones, shared oklch L/C):
//    french  #26408B   cobalt  #1F5C9E   sea     #1A7891
//    pine    #2A7B6E   iris    #553C8E   plum    #7A3370

@immutable
class MomentumColors extends ThemeExtension<MomentumColors> {
  const MomentumColors({
    required this.bgCanvas,
    required this.surface,
    required this.inkPrimary,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.hairline,
    required this.hairlineStrong,
    required this.scrim,
    required this.archiveReveal,
    required this.danger,
  });

  final Color bgCanvas;
  final Color surface;
  final Color inkPrimary;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color hairline;
  final Color hairlineStrong;
  final Color scrim;
  final Color archiveReveal; // Deep Twilight #0F084B
  final Color danger;       // dusk-rose for destructive actions

  static const light = MomentumColors(
    bgCanvas:       Color(0xFFDCECEB),
    surface:        Color(0xFFFFFFFF),
    inkPrimary:     Color(0xFF0D0221),
    inkSecondary:   Color(0xFF26408B),
    inkTertiary:    Color(0xFF7A96B0),
    hairline:       Color(0x1A0D0221),
    hairlineStrong: Color(0x380D0221),
    scrim:          Color(0x660D0221),
    archiveReveal:  Color(0xFF0F084B),
    danger:         Color(0xFFA6446D),
  );

  static const dark = MomentumColors(
    bgCanvas:       Color(0xFF0D0221),
    surface:        Color(0xFF170A3C),
    inkPrimary:     Color(0xFFC2E7D9),
    inkSecondary:   Color(0xFFA6CFD5),
    inkTertiary:    Color(0xFF6A7E92),
    hairline:       Color(0x1AC2E7D9),
    hairlineStrong: Color(0x38C2E7D9),
    scrim:          Color(0x99000000),
    archiveReveal:  Color(0xFF0F084B),
    danger:         Color(0xFFA6446D),
  );

  @override
  MomentumColors copyWith({
    Color? bgCanvas,
    Color? surface,
    Color? inkPrimary,
    Color? inkSecondary,
    Color? inkTertiary,
    Color? hairline,
    Color? hairlineStrong,
    Color? scrim,
    Color? archiveReveal,
    Color? danger,
  }) {
    return MomentumColors(
      bgCanvas:       bgCanvas       ?? this.bgCanvas,
      surface:        surface        ?? this.surface,
      inkPrimary:     inkPrimary     ?? this.inkPrimary,
      inkSecondary:   inkSecondary   ?? this.inkSecondary,
      inkTertiary:    inkTertiary    ?? this.inkTertiary,
      hairline:       hairline       ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      scrim:          scrim          ?? this.scrim,
      archiveReveal:  archiveReveal  ?? this.archiveReveal,
      danger:         danger         ?? this.danger,
    );
  }

  @override
  MomentumColors lerp(MomentumColors? other, double t) {
    if (other == null) return this;
    return MomentumColors(
      bgCanvas:       Color.lerp(bgCanvas,       other.bgCanvas,       t)!,
      surface:        Color.lerp(surface,        other.surface,        t)!,
      inkPrimary:     Color.lerp(inkPrimary,     other.inkPrimary,     t)!,
      inkSecondary:   Color.lerp(inkSecondary,   other.inkSecondary,   t)!,
      inkTertiary:    Color.lerp(inkTertiary,    other.inkTertiary,    t)!,
      hairline:       Color.lerp(hairline,       other.hairline,       t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      scrim:          Color.lerp(scrim,          other.scrim,          t)!,
      archiveReveal:  Color.lerp(archiveReveal,  other.archiveReveal,  t)!,
      danger:         Color.lerp(danger,         other.danger,         t)!,
    );
  }
}

// ── Six habit pigments ───────────────────────────────────────────────────────

class MomentumPigments {
  MomentumPigments._();

  static const french = Color(0xFF26408B);
  static const cobalt = Color(0xFF1F5C9E);
  static const sea    = Color(0xFF1A7891);
  static const pine   = Color(0xFF2A7B6E);
  static const iris   = Color(0xFF553C8E);
  static const plum   = Color(0xFF7A3370);

  static const all = [french, cobalt, sea, pine, iris, plum];
  static const names = ['French', 'Cobalt', 'Sea', 'Pine', 'Iris', 'Plum'];

  static Color fromHex(String? hex) {
    if (hex == null) return french;
    final h = hex.replaceFirst('#', '');
    if (h.length != 6) return french;
    return Color(int.parse('FF$h', radix: 16));
  }

  static Color fromIndex(int i) => all[i.clamp(0, all.length - 1)];
}

// ── Theme builder ────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color inkPrimary, Color inkSecondary) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      // Display — Fraunces serif
      displayLarge: GoogleFonts.fraunces(
        fontSize: 56, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -1.4, height: 1,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 40, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -1.0, height: 1,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 28, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -0.6, height: 1.2,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 22, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -0.4, height: 1.2,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 20, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 17, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -0.2,
      ),
      // Body — Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -0.1,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: inkPrimary, letterSpacing: -0.1,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: inkSecondary, letterSpacing: -0.1,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: inkPrimary, letterSpacing: -0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: inkSecondary, letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: inkSecondary, letterSpacing: 1.4,
      ),
    );
  }

  static ThemeData light() {
    const c = MomentumColors.light;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: MomentumPigments.french,
        brightness: Brightness.light,
        surface: c.surface,
      ),
      scaffoldBackgroundColor: c.bgCanvas,
      textTheme: _buildTextTheme(c.inkPrimary, c.inkSecondary),
      dividerColor: c.hairline,
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 0),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgCanvas,
        foregroundColor: c.inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22, fontWeight: FontWeight.w400,
          color: c.inkPrimary, letterSpacing: -0.4,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.inkPrimary,
        foregroundColor: c.bgCanvas,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      useMaterial3: true,
      extensions: const [c],
    );
  }

  static ThemeData dark() {
    const c = MomentumColors.dark;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: MomentumPigments.french,
        brightness: Brightness.dark,
        surface: c.surface,
      ),
      scaffoldBackgroundColor: c.bgCanvas,
      textTheme: _buildTextTheme(c.inkPrimary, c.inkSecondary),
      dividerColor: c.hairline,
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 0),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgCanvas,
        foregroundColor: c.inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22, fontWeight: FontWeight.w400,
          color: c.inkPrimary, letterSpacing: -0.4,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.inkPrimary,
        foregroundColor: c.bgCanvas,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      useMaterial3: true,
      extensions: const [c],
    );
  }
}

// ── Convenience extension ────────────────────────────────────────────────────

extension MomentumTheme on BuildContext {
  MomentumColors get mc =>
      Theme.of(this).extension<MomentumColors>() ?? MomentumColors.light;
}
