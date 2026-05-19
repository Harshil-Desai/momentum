import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../widgets/frequency_form_section.dart';
import '../widgets/icon_picker.dart';
import 'create_habit_screen.dart' show StackAfterPicker, PigmentPicker, HabitTypeChip, HabitSectionLabel;
import '../../../core/theme/app_theme.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final Habit habit;
  const EditHabitScreen({super.key, required this.habit});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _iconPath;
  late final TextEditingController _noteController;
  late final TextEditingController _twoMinuteController;
  String? _selectedColor;
  String? _stackAfterHabitId;
  late bool _isNegative;
  late HabitFrequency _frequency;
  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameController = TextEditingController(text: h.name);
    _iconPath = (h.icon != null && h.icon!.isNotEmpty) ? h.icon! : kDefaultHabitIcon;
    _noteController = TextEditingController(text: h.note ?? '');
    _twoMinuteController =
        TextEditingController(text: h.twoMinuteVersion ?? '');
    _selectedColor = h.color;
    _stackAfterHabitId = h.stackAfterHabitId;
    _isNegative = h.isNegative;
    _frequency = h.frequency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _twoMinuteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(habitsProvider.notifier).updateHabit(
          habitId: widget.habit.id,
          name: _nameController.text.trim(),
          icon: _iconPath,
          color: _selectedColor ?? '',
          note: _noteController.text.trim(),
          twoMinuteVersion: _twoMinuteController.text.trim(),
          stackAfterHabitId: _isNegative ? null : (_stackAfterHabitId ?? ''),
          isNegative: _isNegative,
          frequency: _frequency,
          subtasks: [],
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ref.invalidate(habitHistoryDataProvider(widget.habit.id));
      ref.invalidate(habitStreakProvider(widget.habit.id));
      context.pop();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update habit')),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => _DeleteSheet(habitName: widget.habit.name),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    await ref
        .read(habitsProvider.notifier)
        .archiveHabit(widget.habit.id);
    if (mounted) {
      context.go('/habits');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.chevron_left,
                            size: 28, color: mc.inkPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Text(
                  'Edit habit',
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: mc.inkPrimary,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Icon picker ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: HabitSectionLabel('ICON', mc),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: HabitIconPicker(
                  selectedIcon: _iconPath,
                  onIconSelected: (p) => setState(() => _iconPath = p),
                  backgroundColor: _selectedColor != null
                      ? CadencePigments.fromHex(_selectedColor).withAlpha(26)
                      : mc.hairline,
                  iconColor: _selectedColor != null
                      ? CadencePigments.fromHex(_selectedColor)
                      : mc.inkPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // ── Name ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: HabitSectionLabel('NAME', mc),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: mc.inkPrimary,
                    letterSpacing: -0.3,
                  ),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: mc.hairlineStrong),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: mc.inkPrimary, width: 1.5),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: mc.hairlineStrong),
                    ),
                    contentPadding: const EdgeInsets.only(bottom: 8),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length > 100) return 'Max 100 characters';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ── Habit type ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: HabitSectionLabel('BUILDING OR AVOIDING', mc),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    HabitTypeChip(
                      label: 'Building',
                      selected: !_isNegative,
                      onTap: () => setState(() => _isNegative = false),
                      mc: mc,
                    ),
                    const SizedBox(width: 10),
                    HabitTypeChip(
                      label: 'Avoiding',
                      selected: _isNegative,
                      onTap: () => setState(() => _isNegative = true),
                      mc: mc,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Pigment ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: HabitSectionLabel('PIGMENT', mc),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PigmentPicker(
                  selected: _selectedColor,
                  onChanged: (hex) => setState(() => _selectedColor = hex),
                  mc: mc,
                ),
              ),

              const SizedBox(height: 28),

              // ── Frequency ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HabitSectionLabel('FREQUENCY', mc),
                    const SizedBox(height: 12),
                    FrequencyFormSection(
                      initial: _frequency,
                      onChanged: (f) => setState(() => _frequency = f),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Why this matters ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HabitSectionLabel('WHY THIS MATTERS', mc),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: mc.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: mc.inkPrimary,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Helps me feel calm before work',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 14, color: mc.inkTertiary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── On hard days ─────────────────────────────────────────
              if (!_isNegative)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HabitSectionLabel('ON HARD DAYS', mc),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: mc.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _twoMinuteController,
                          maxLines: 2,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: mc.inkPrimary,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Just read one paragraph',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 14, color: mc.inkTertiary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ── Stack after ──────────────────────────────────────────
              if (!_isNegative)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HabitSectionLabel('STACK AFTER', mc),
                      const SizedBox(height: 10),
                      StackAfterPicker(
                        currentHabitId: widget.habit.id,
                        selectedId: _stackAfterHabitId,
                        onChanged: (id) =>
                            setState(() => _stackAfterHabitId = id),
                        mc: mc,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // ── Delete link ───────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _isDeleting ? null : _delete,
                  child: Text(
                    _isDeleting ? 'Archiving…' : 'Delete this habit',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: mc.danger,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ── Save button ───────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: GestureDetector(
            onTap: _isLoading ? null : _submit,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: mc.inkPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: mc.bgCanvas,
                        ),
                      )
                    : Text(
                        'Save',
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
        ),
      ),
    );
  }
}

// ── Delete sheet ──────────────────────────────────────────────────────────────

class _DeleteSheet extends StatelessWidget {
  final String habitName;
  const _DeleteSheet({required this.habitName});

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'Archive ',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  color: mc.inkPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: habitName,
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: mc.inkPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: '?',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  color: mc.inkPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            'This will move the habit to your past habits.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: mc.inkSecondary,
              letterSpacing: -0.1,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => Navigator.pop(context, true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Text(
                'Archive',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: mc.danger,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: mc.hairline),
          InkWell(
            onTap: () => Navigator.pop(context, false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Text(
                'Keep going',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: mc.inkPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
