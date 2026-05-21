import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/template.dart';
import '../providers/templates_provider.dart';
import '../../habits/providers/habits_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api_client.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/theme/app_theme.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.chevron_left,
                      size: 28, color: mc.inkPrimary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Borrow a beginning.',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: mc.inkPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Adopt any habit to make it your own.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: mc.inkTertiary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: mc.hairline),

            // ── Body ──────────────────────────────────────────────────
            Expanded(
              child: templatesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Could not load templates',
                        style: GoogleFonts.inter(color: mc.inkSecondary),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () =>
                            ref.read(templatesProvider.notifier).build(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: mc.hairlineStrong),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'Try again',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: mc.inkPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (grouped) => grouped.isEmpty
                    ? Center(
                        child: Text(
                          'No templates available.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: mc.inkTertiary,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 40),
                        children: grouped.entries.map((entry) {
                          return _CategorySection(
                            category: entry.key,
                            templates: entry.value,
                            mc: mc,
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final String category;
  final List<HabitTemplate> templates;
  final CadenceColors mc;

  const _CategorySection({
    required this.category,
    required this.templates,
    required this.mc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: Text(
            category,
            style: GoogleFonts.fraunces(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: mc.inkSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        ...templates.map((t) => _TemplateRow(template: t, mc: mc)),
      ],
    );
  }
}

// ── Template row ──────────────────────────────────────────────────────────────

class _TemplateRow extends ConsumerStatefulWidget {
  final HabitTemplate template;
  final CadenceColors mc;

  const _TemplateRow({required this.template, required this.mc});

  @override
  ConsumerState<_TemplateRow> createState() => _TemplateRowState();
}

class _TemplateRowState extends ConsumerState<_TemplateRow> {
  bool _loading = false;

  Color get _accent => CadencePigments.fromHex(widget.template.color);

  Future<void> _adopt() async {
    setState(() => _loading = true);
    final ok = await ref
        .read(templatesProvider.notifier)
        .adopt(widget.template.id);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      // Pull the newly adopted habit from server into local DB, then refresh UI.
      final userId = ref.read(authProvider).value?.userId ?? '';
      await SyncService(ref.read(dioProvider)).fullRefresh(userId);
      ref.invalidate(habitsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${widget.template.name}" added to your habits'),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add template')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final mc = widget.mc;
    final accent = _accent;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    t.icon ?? '📌',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: mc.inkPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (t.note != null && t.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        t.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: mc.inkTertiary,
                          letterSpacing: -0.05,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        t.frequency.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: mc.inkTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (_loading)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: mc.inkPrimary,
                  ),
                )
              else
                GestureDetector(
                  onTap: _adopt,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: mc.hairlineStrong),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Adopt',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: mc.inkPrimary,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: mc.hairline, indent: 24, endIndent: 24),
      ],
    );
  }
}
