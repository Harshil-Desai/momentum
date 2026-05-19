import 'package:flutter/material.dart';
import '../models/habit.dart';

class FrequencyFormSection extends StatefulWidget {
  final HabitFrequency initial;
  final ValueChanged<HabitFrequency> onChanged;

  const FrequencyFormSection({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<FrequencyFormSection> createState() => _FrequencyFormSectionState();
}

class _FrequencyFormSectionState extends State<FrequencyFormSection> {
  late String _type;
  late List<bool> _days; // length 7, Sun-Sat
  late int _timesPerWeek;
  late int _everyNDays;

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _type = f.type;
    _days = List.generate(7, (i) => f.days?.contains(i) ?? false);
    _timesPerWeek = f.times ?? 3;
    _everyNDays = f.everyNDays ?? 2;
  }

  HabitFrequency _current() {
    switch (_type) {
      case 'weekly':
        final selected = [for (int i = 0; i < 7; i++) if (_days[i]) i];
        return HabitFrequency(type: 'weekly', days: selected);
      case 'times_per_week':
        return HabitFrequency(type: 'times_per_week', times: _timesPerWeek);
      case 'interval':
        return HabitFrequency(type: 'interval', everyNDays: _everyNDays);
      default:
        return const HabitFrequency(type: 'daily');
    }
  }

  void _notify() => widget.onChanged(_current());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'daily', label: Text('Daily')),
            ButtonSegment(value: 'weekly', label: Text('Weekly')),
            ButtonSegment(value: 'times_per_week', label: Text('X/week')),
            ButtonSegment(value: 'interval', label: Text('Interval')),
          ],
          selected: {_type},
          onSelectionChanged: (s) {
            setState(() => _type = s.first);
            _notify();
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
        if (_type == 'weekly') ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final selected = _days[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _days[i] = !_days[i]);
                  _notify();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      _dayLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
        if (_type == 'times_per_week') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Times per week: '),
              const SizedBox(width: 8),
              _Counter(
                value: _timesPerWeek,
                min: 1,
                max: 7,
                onChanged: (v) {
                  setState(() => _timesPerWeek = v);
                  _notify();
                },
              ),
            ],
          ),
        ],
        if (_type == 'interval') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Every '),
              const SizedBox(width: 8),
              _Counter(
                value: _everyNDays,
                min: 1,
                max: 30,
                onChanged: (v) {
                  setState(() => _everyNDays = v);
                  _notify();
                },
              ),
              const SizedBox(width: 8),
              const Text('days'),
            ],
          ),
        ],
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Counter({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 22,
          visualDensity: VisualDensity.compact,
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 22,
          visualDensity: VisualDensity.compact,
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
