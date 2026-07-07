import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/report_filter.dart';
import '../providers/report_provider.dart';

class ReportFilters extends ConsumerStatefulWidget {
  const ReportFilters({super.key});

  @override
  ConsumerState<ReportFilters> createState() => _ReportFiltersState();
}

class _ReportFiltersState extends ConsumerState<ReportFilters> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  ReportGranularity _granularity = ReportGranularity.daily;
  String? _userType;
  String? _typeIdentification;

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final initial = isFrom ? _dateFrom : _dateTo;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  void _apply() {
    final filter = ReportFilter(
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      granularity: _granularity,
      userType: _userType,
      typeIdentification: _typeIdentification,
    );
    ref.read(reportProvider.notifier).generate(filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtres', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _DateChip(
                  label: 'Du',
                  value: _dateFrom,
                  onTap: () => _pickDate(context, true),
                  onClear: () => setState(() => _dateFrom = null),
                ),
                _DateChip(
                  label: 'Au',
                  value: _dateTo,
                  onTap: () => _pickDate(context, false),
                  onClear: () => setState(() => _dateTo = null),
                ),
                DropdownButtonFormField<ReportGranularity>(
                  initialValue: _granularity,
                  decoration: const InputDecoration(
                    labelText: 'Période',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: ReportGranularity.daily, child: Text('Par jour')),
                    DropdownMenuItem(value: ReportGranularity.weekly, child: Text('Par semaine')),
                    DropdownMenuItem(value: ReportGranularity.monthly, child: Text('Par mois')),
                  ],
                  onChanged: (v) => setState(() => _granularity = v ?? ReportGranularity.daily),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _userType,
                  decoration: const InputDecoration(
                    labelText: 'Type de personne',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(value: 'EMPLOYE', child: Text('Employés')),
                    DropdownMenuItem(value: 'STAGIAIRE', child: Text('Stagiaires')),
                    DropdownMenuItem(value: 'VISITEUR', child: Text('Visiteurs')),
                  ],
                  onChanged: (v) => setState(() => _userType = v),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _typeIdentification,
                  decoration: const InputDecoration(
                    labelText: 'Méthode',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Toutes')),
                    DropdownMenuItem(value: 'QR', child: Text('QR Code')),
                    DropdownMenuItem(value: 'FACE', child: Text('Reconnaissance faciale')),
                  ],
                  onChanged: (v) => setState(() => _typeIdentification = v),
                ),
                FilledButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Générer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(),
        suffixIcon: value != null
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Text(
          value != null
              ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
              : 'Sélectionner',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: value != null ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
