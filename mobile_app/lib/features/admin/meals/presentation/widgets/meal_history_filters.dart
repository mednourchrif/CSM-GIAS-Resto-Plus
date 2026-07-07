import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealHistoryFilters extends ConsumerStatefulWidget {
  final String? currentDateFrom;
  final String? currentDateTo;
  final String? currentCategorieUuid;
  final String? currentTypeIdentification;
  final String? currentUserType;
  final void Function({String? dateFrom, String? dateTo}) onDateChanged;
  final void Function(String? categorieUuid) onCategorieChanged;
  final void Function(String? typeIdentification) onTypeIdentificationChanged;
  final void Function(String? userType) onUserTypeChanged;
  final VoidCallback onReset;

  const MealHistoryFilters({
    super.key,
    this.currentDateFrom,
    this.currentDateTo,
    this.currentCategorieUuid,
    this.currentTypeIdentification,
    this.currentUserType,
    required this.onDateChanged,
    required this.onCategorieChanged,
    required this.onTypeIdentificationChanged,
    required this.onUserTypeChanged,
    required this.onReset,
  });

  @override
  ConsumerState<MealHistoryFilters> createState() => _MealHistoryFiltersState();
}

class _MealHistoryFiltersState extends ConsumerState<MealHistoryFilters> {
  final _dateFromCtrl = TextEditingController();
  final _dateToCtrl = TextEditingController();
  String? _typeIdentification;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _dateFromCtrl.text = widget.currentDateFrom ?? '';
    _dateToCtrl.text = widget.currentDateTo ?? '';
    _typeIdentification = widget.currentTypeIdentification;
    _userType = widget.currentUserType;
  }

  @override
  void dispose() {
    _dateFromCtrl.dispose();
    _dateToCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtres',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Période', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateFromCtrl,
                    decoration: InputDecoration(
                      labelText: 'Date début',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: const Icon(Icons.calendar_today, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    readOnly: true,
                    onTap: () => _pickDate(_dateFromCtrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dateToCtrl,
                    decoration: InputDecoration(
                      labelText: 'Date fin',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: const Icon(Icons.calendar_today, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    readOnly: true,
                    onTap: () => _pickDate(_dateToCtrl),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Type d\'identification', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Tous')),
                ButtonSegment(value: 'FACE', label: Text('Visage')),
                ButtonSegment(value: 'QR', label: Text('QR Code')),
              ],
              selected: {_typeIdentification},
              onSelectionChanged: (v) {
                setState(() => _typeIdentification = v.first);
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            Text('Type d\'utilisateur', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Tous')),
                ButtonSegment(value: 'EMPLOYE', label: Text('Employé')),
                ButtonSegment(value: 'STAGIAIRE', label: Text('Stagiaire')),
                ButtonSegment(value: 'VISITEUR', label: Text('Visiteur')),
              ],
              selected: {_userType},
              onSelectionChanged: (v) {
                setState(() => _userType = v.first);
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onReset();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Réinitialiser'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    widget.onDateChanged(
                      dateFrom: _dateFromCtrl.text.isNotEmpty
                          ? _dateFromCtrl.text
                          : null,
                      dateTo: _dateToCtrl.text.isNotEmpty
                          ? _dateToCtrl.text
                          : null,
                    );
                    widget.onTypeIdentificationChanged(_typeIdentification);
                    widget.onUserTypeChanged(_userType);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Appliquer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) {
      final formatted =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      ctrl.text = formatted;
    }
  }
}
