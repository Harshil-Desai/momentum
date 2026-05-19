import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/frequency_form_section.dart';
import '../widgets/icon_picker.dart';
import '../../../core/theme/app_theme.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _iconPath = kDefaultHabitIcon;
  final _noteController = TextEditingController();
  final _twoMinuteController = TextEditingController();
  String? _selectedColor;
  String? _stackAfterHabitId;
  bool _isNegative = false;
  HabitFrequency _frequency = const HabitFrequency(type: 'daily');
  TimeOfDay? _pendingReminder;
  bool _isLoading = false;

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

    final created = await ref.read(habitsProvider.notifier).createHabit(
          name: _nameController.text.trim(),
          icon: _iconPath,
          color: _selectedColor,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          twoMinuteVersion: _twoMinuteController.text.trim().isEmpty
              ? null
              : _twoMinuteController.text.trim(),
          stackAfterHabitId: _stackAfterHabitId,
          isNegative: _isNegative,
          frequency: _frequency,
        );

    if (created != null && _pendingReminder != null) {
      await ref
          .read(habitReminderNotifierProvider(created.id).notifier)
          .set(created, _pendingReminder!);
      // Permission denied is handled silently here — habit was still created.
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (created != null && mounted) {
      context.pop();
    } else if (created == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create habit')),
      );
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
                  'What will you do?',
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: mc.inkPrimary,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Name input ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: mc.inkPrimary,
                    letterSpacing: -0.3,
                  ),
                  decoration: InputDecoration(
                    hintText: _isNegative
                        ? 'e.g. Doomscrolling before bed'
                        : 'e.g. Morning run',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 20,
                      color: mc.inkTertiary,
                      letterSpacing: -0.3,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: mc.hairlineStrong),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: mc.inkPrimary, width: 1.5),
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

              const SizedBox(height: 32),

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

              const SizedBox(height: 28),

              // ── Pigment swatches ──────────────────────────────────────
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

              // ── Reminder ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HabitSectionLabel('REMINDER', mc),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: mc.hairlineStrong, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mc.hairline,
                            ),
                            child: Center(
                              child: Icon(
                                _pendingReminder != null
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_none_outlined,
                                size: 18,
                                color: mc.inkPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _pendingReminder != null
                                  ? 'Daily at ${_pendingReminder!.hour.toString().padLeft(2, '0')}:${_pendingReminder!.minute.toString().padLeft(2, '0')}'
                                  : 'No reminder set',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: mc.inkPrimary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _pendingReminder ??
                                    const TimeOfDay(hour: 8, minute: 0),
                                helpText: 'Set daily reminder',
                              );
                              if (picked != null) {
                                setState(() => _pendingReminder = picked);
                              }
                            },
                            child: Text(
                              _pendingReminder != null ? 'Change' : 'Set time',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: mc.inkSecondary,
                                letterSpacing: -0.05,
                              ),
                            ),
                          ),
                          if (_pendingReminder != null) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _pendingReminder = null),
                              child: Icon(Icons.close,
                                  size: 16, color: mc.inkTertiary),
                            ),
                          ],
                        ],
                      ),
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
                            fontSize: 14,
                            color: mc.inkTertiary,
                          ),
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
                              fontSize: 14,
                              color: mc.inkTertiary,
                            ),
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
                        currentHabitId: null,
                        selectedId: _stackAfterHabitId,
                        onChanged: (id) =>
                            setState(() => _stackAfterHabitId = id),
                        mc: mc,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      // ── Submit button ─────────────────────────────────────────────────
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
                        'Make the promise.',
                        style: GoogleFonts.fraunces(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: mc.bgCanvas,
                          letterSpacing: -0.2,
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

// ── Pigment picker ────────────────────────────────────────────────────────────

class PigmentPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  final CadenceColors mc;

  const PigmentPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.mc,
  });

  @override
  Widget build(BuildContext context) {
    const hexes = [
      '#26408B', '#1F5C9E', '#1A7891', '#2A7B6E', '#553C8E', '#7A3370',
    ];

    return Row(
      children: List.generate(CadencePigments.all.length, (i) {
        final color = CadencePigments.all[i];
        final hex = hexes[i];
        final isSelected = selected == hex;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(isSelected ? null : hex),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 40 : 32,
                  height: isSelected ? 40 : 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: mc.inkPrimary, width: 2.5)
                        : null,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Text(
                    CadencePigments.names[i],
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: mc.inkSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Type chip ─────────────────────────────────────────────────────────────────

class HabitTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final CadenceColors mc;

  const HabitTypeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.mc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? mc.inkPrimary : Colors.transparent,
          border: Border.all(
            color: selected ? mc.inkPrimary : mc.hairlineStrong,
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? mc.bgCanvas : mc.inkPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class HabitSectionLabel extends StatelessWidget {
  final String text;
  final CadenceColors mc;
  const HabitSectionLabel(this.text, this.mc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.4,
        color: mc.inkTertiary,
      ),
    );
  }
}

// ── Stack after picker ────────────────────────────────────────────────────────

class StackAfterPicker extends ConsumerWidget {
  final String? currentHabitId;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final CadenceColors mc;

  const StackAfterPicker({
    super.key,
    required this.currentHabitId,
    required this.selectedId,
    required this.onChanged,
    required this.mc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final habits = habitsAsync.valueOrNull ?? <Habit>[];
    final options = habits
        .where((h) => h.id != currentHabitId && !h.isNegative)
        .toList();

    return DropdownButtonFormField<String>(
      value: selectedId,
      dropdownColor: mc.surface,
      style: GoogleFonts.inter(fontSize: 14, color: mc.inkPrimary),
      decoration: InputDecoration(
        hintText: 'None',
        hintStyle: GoogleFonts.inter(fontSize: 14, color: mc.inkTertiary),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: mc.hairlineStrong),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: mc.inkPrimary, width: 1.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: mc.hairlineStrong),
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('None',
              style: GoogleFonts.inter(fontSize: 14, color: mc.inkTertiary)),
        ),
        ...options.map((h) => DropdownMenuItem<String>(
              value: h.id,
              child: Text(
                '${h.icon ?? ''} ${h.name}'.trim(),
                overflow: TextOverflow.ellipsis,
                style:
                    GoogleFonts.inter(fontSize: 14, color: mc.inkPrimary),
              ),
            )),
      ],
      onChanged: onChanged,
    );
  }
}

// ── Emoji input dialog ────────────────────────────────────────────────────────

class _EmojiInputDialog extends StatefulWidget {
  final String initial;
  const _EmojiInputDialog({required this.initial});

  @override
  State<_EmojiInputDialog> createState() => _EmojiInputDialogState();
}

class _EmojiInputDialogState extends State<_EmojiInputDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return AlertDialog(
      backgroundColor: mc.surface,
      title: Text('Choose an emoji',
          style: GoogleFonts.fraunces(
              fontSize: 18, color: mc.inkPrimary, letterSpacing: -0.3)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
          hintText: '📌',
          hintStyle: const TextStyle(fontSize: 24),
          border:
              UnderlineInputBorder(borderSide: BorderSide(color: mc.hairline)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: mc.inkTertiary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: Text('Done',
              style: GoogleFonts.inter(
                  color: mc.inkPrimary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
