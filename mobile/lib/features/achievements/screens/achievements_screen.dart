import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/achievements_provider.dart';
import '../models/achievement.dart';
import '../../../core/theme/app_theme.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final async = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load achievements',
                  style: GoogleFonts.inter(color: mc.inkSecondary)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    ref.read(achievementsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => _AchievementsBody(data: data, mc: mc, ref: ref),
      ),
    );
  }
}

class _AchievementsBody extends StatelessWidget {
  const _AchievementsBody({
    required this.data,
    required this.mc,
    required this.ref,
  });

  final AchievementsData data;
  final CadenceColors mc;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final earned = data.earned;
    final locked = data.all.where((a) => a.isLocked).toList();
    final inProgress = data.inProgress;
    final featured = earned.isNotEmpty ? earned.first : null;
    final totalCount = data.all.length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(achievementsProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // ── Back button + editorial header ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 22, color: mc.inkPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The mantelpiece',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: mc.inkTertiary,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Achievements',
                      style: GoogleFonts.fraunces(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: mc.inkPrimary,
                        letterSpacing: -0.7,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A quiet record of the promises you\'ve kept.',
                      style: GoogleFonts.fraunces(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: mc.inkTertiary,
                        letterSpacing: -0.05,
                        height: 1.5,
                      ),
                    ),
                    // Count + progress bar
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${earned.length}',
                              style: GoogleFonts.fraunces(
                                fontSize: 44,
                                fontWeight: FontWeight.w400,
                                color: mc.inkPrimary,
                                letterSpacing: -1.0,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'of',
                              style: GoogleFonts.fraunces(
                                fontSize: 22,
                                fontStyle: FontStyle.italic,
                                color: mc.inkTertiary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$totalCount',
                              style: GoogleFonts.fraunces(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: mc.inkSecondary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'EARNED',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: mc.inkTertiary,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 3,
                        color: mc.hairline,
                        child: FractionallySizedBox(
                          widthFactor: totalCount == 0
                              ? 0
                              : earned.length / totalCount,
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            color: mc.inkSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Featured (most recently earned) ────────────────────────────
            if (featured != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Most recent', mc: mc),
                      const SizedBox(height: 16),
                      _FeaturedCard(item: featured, mc: mc),
                    ],
                  ),
                ),
              ),

            // ── Earned grid (skip featured) ─────────────────────────────────
            if (earned.length > 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Earned', mc: mc),
                      const SizedBox(height: 18),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 28,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: earned.length - 1,
                        itemBuilder: (_, i) =>
                            _MedallionTile(item: earned[i + 1], mc: mc),
                      ),
                    ],
                  ),
                ),
              ),

            // ── In progress ─────────────────────────────────────────────────
            if (inProgress.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: _SectionLabel(label: 'In progress', mc: mc),
                      ),
                      ...inProgress
                          .map((p) => _ProgressRow(item: p, mc: mc)),
                    ],
                  ),
                ),
              ),

            // ── Still to earn (locked) ──────────────────────────────────────
            if (locked.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: _SectionLabel(label: 'Still to earn', mc: mc),
                      ),
                      ...locked.map((a) => _LockedRow(item: a, mc: mc)),
                    ],
                  ),
                ),
              ),

            // ── Closing thought ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 1,
                      color: mc.hairline,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'The point isn\'t to collect them all.\nIt\'s that they collected themselves.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fraunces(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: mc.inkTertiary,
                        letterSpacing: -0.05,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.mc});
  final String label;
  final CadenceColors mc;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: mc.inkTertiary,
        letterSpacing: 1.6,
      ),
    );
  }
}

// ── Featured card ─────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.item, required this.mc});
  final AchievementItem item;
  final CadenceColors mc;

  @override
  Widget build(BuildContext context) {
    final accent = mc.inkSecondary;
    final tint = accent.withAlpha(26); // ~10%
    final tintBorder = accent.withAlpha(46); // ~18%

    return Container(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tintBorder),
      ),
      child: Stack(
        children: [
          // Radial gradient
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.6),
                    radius: 1.2,
                    colors: [accent.withAlpha(46), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                // Medallion
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(26),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withAlpha(56), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      item.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.earnedAt != null)
                        Text(
                          'Earned ${_fmtDate(item.earnedAt!)}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accent,
                            letterSpacing: 1.6,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: mc.inkPrimary,
                          letterSpacing: -0.4,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: GoogleFonts.fraunces(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: mc.inkSecondary,
                          letterSpacing: -0.1,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ── Medallion tile (3-col grid) ───────────────────────────────────────────────

class _MedallionTile extends StatelessWidget {
  const _MedallionTile({required this.item, required this.mc});
  final AchievementItem item;
  final CadenceColors mc;

  @override
  Widget build(BuildContext context) {
    final accent = mc.inkSecondary;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: accent.withAlpha(26),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withAlpha(56), width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(51),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(item.icon, style: const TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: mc.inkPrimary,
            letterSpacing: -0.1,
            height: 1.3,
          ),
        ),
        if (item.earnedAt != null) ...[
          const SizedBox(height: 2),
          Text(
            _fmtDate(item.earnedAt!),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: mc.inkTertiary,
            ),
          ),
        ],
      ],
    );
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ── Progress row (in-progress achievement) ───────────────────────────────────

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item, required this.mc});
  final ProgressItem item;
  final CadenceColors mc;

  @override
  Widget build(BuildContext context) {
    final progress =
        (item.currentValue / item.targetValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: mc.inkPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mc.inkTertiary,
                    letterSpacing: -0.05,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: mc.hairline,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(mc.inkSecondary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.currentValue} / ${item.targetValue}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: mc.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Locked row (still to earn) ───────────────────────────────────────────────

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.item, required this.mc});
  final AchievementItem item;
  final CadenceColors mc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.35,
            child:
                Text(item.icon, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: mc.inkTertiary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mc.inkTertiary.withAlpha(140),
                    letterSpacing: -0.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
