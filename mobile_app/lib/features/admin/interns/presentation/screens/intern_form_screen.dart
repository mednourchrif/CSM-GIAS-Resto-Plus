import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../domain/entities/intern.dart';
import '../providers/intern_provider.dart';

class InternFormScreen extends ConsumerStatefulWidget {
  final Intern? intern;

  const InternFormScreen({super.key, this.intern});

  @override
  ConsumerState<InternFormScreen> createState() => _InternFormScreenState();
}

class _InternFormScreenState extends ConsumerState<InternFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _matriculeController;
  late DateTime _dateDebutStage;
  late DateTime _dateFinStage;
  String _statut = 'ACTIF';
  bool _isSaving = false;

  bool get _isEditing => widget.intern != null;

  @override
  void initState() {
    super.initState();
    final i = widget.intern;
    _nomController = TextEditingController(text: i?.nom ?? '');
    _prenomController = TextEditingController(text: i?.prenom ?? '');
    _matriculeController = TextEditingController(text: i?.matricule ?? '');
    _dateDebutStage = i?.dateDebutStage ?? DateTime.now();
    _dateFinStage = i?.dateFinStage ?? DateTime.now().add(const Duration(days: 90));
    _statut = i?.statut ?? 'ACTIF';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _dateDebutStage : _dateFinStage,
      firstDate: isStart ? DateTime(2020) : _dateDebutStage,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dateDebutStage = picked;
          if (_dateFinStage.isBefore(picked)) {
            _dateFinStage = picked;
          }
        } else {
          _dateFinStage = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateFinStage.isBefore(_dateDebutStage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de fin doit être après la date de début.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    bool success;
    if (_isEditing) {
      success = await ref.read(internProvider.notifier).updateIntern(
            widget.intern!.uuid,
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            matricule: _matriculeController.text.trim(),
            dateDebutStage: _dateDebutStage,
            dateFinStage: _dateFinStage,
            statut: _statut,
          );
    } else {
      success = await ref.read(internProvider.notifier).createIntern(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            matricule: _matriculeController.text.trim(),
            dateDebutStage: _dateDebutStage,
            dateFinStage: _dateFinStage,
            statut: _statut,
          );
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Stagiaire modifié avec succès.'
                : 'Stagiaire créé avec succès.',
          ),
        ),
      );
    } else {
      final error = ref.read(internProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Une erreur est survenue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isEditing ? 'Modifier le stagiaire' : 'Nouveau stagiaire';

    return Dialog(
      insetPadding: const EdgeInsets.all(Spacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomController,
                          decoration: const InputDecoration(
                            labelText: 'Nom *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              Validators.required(v, fieldName: 'Le nom')?.message,
                        ),
                        const SizedBox(height: Spacing.md),
                        TextFormField(
                          controller: _prenomController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              Validators.required(v, fieldName: 'Le prénom')?.message,
                        ),
                        const SizedBox(height: Spacing.md),
                        TextFormField(
                          controller: _matriculeController,
                          decoration: const InputDecoration(
                            labelText: 'Matricule *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              Validators.required(v, fieldName: 'Le matricule')?.message,
                        ),
                        const SizedBox(height: Spacing.md),
                        InkWell(
                          onTap: () => _pickDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Début de stage *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_month_rounded),
                            ),
                            child: Text(
                              '${_dateDebutStage.day.toString().padLeft(2, '0')}/'
                              '${_dateDebutStage.month.toString().padLeft(2, '0')}/'
                              '${_dateDebutStage.year}',
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        InkWell(
                          onTap: () => _pickDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fin de stage *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_month_rounded),
                            ),
                            child: Text(
                              '${_dateFinStage.day.toString().padLeft(2, '0')}/'
                              '${_dateFinStage.month.toString().padLeft(2, '0')}/'
                              '${_dateFinStage.year}',
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _statut,
                          decoration: const InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'ACTIF',
                              child: Text('Actif'),
                            ),
                            DropdownMenuItem(
                              value: 'INACTIF',
                              child: Text('Inactif'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _statut = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: Spacing.sm),
                    FilledButton(
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
