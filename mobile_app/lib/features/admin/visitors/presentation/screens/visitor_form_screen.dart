import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/visitor.dart';
import '../providers/visitor_provider.dart';

class VisitorFormScreen extends ConsumerStatefulWidget {
  final Visitor? visitor;

  const VisitorFormScreen({super.key, this.visitor});

  @override
  ConsumerState<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends ConsumerState<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _emailController;
  late final TextEditingController _societeController;
  late DateTime _dateVisite;
  String _statut = 'ACTIF';
  bool _isSaving = false;

  bool get _isEditing => widget.visitor != null;

  @override
  void initState() {
    super.initState();
    final v = widget.visitor;
    _nomController = TextEditingController(text: v?.nom ?? '');
    _prenomController = TextEditingController(text: v?.prenom ?? '');
    _emailController = TextEditingController(text: v?.email ?? '');
    _societeController = TextEditingController(text: v?.societe ?? '');
    _dateVisite = v?.dateVisite ?? DateTime.now();
    _statut = v?.statut ?? 'ACTIF';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _societeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateVisite,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dateVisite = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    bool success;
    if (_isEditing) {
      success = await ref.read(visitorProvider.notifier).updateVisitor(
            widget.visitor!.uuid,
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            societe: _societeController.text.trim().isEmpty
                ? null
                : _societeController.text.trim(),
            dateVisite: _dateVisite,
            statut: _statut,
          );
    } else {
      success = await ref.read(visitorProvider.notifier).createVisitor(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            societe: _societeController.text.trim().isEmpty
                ? null
                : _societeController.text.trim(),
            dateVisite: _dateVisite,
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
                ? 'Visiteur modifié avec succès.'
                : 'Visiteur créé avec succès.',
          ),
        ),
      );
    } else {
      final error = ref.read(visitorProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Une erreur est survenue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isEditing ? 'Modifier le visiteur' : 'Nouveau visiteur';

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
                              v == null || v.trim().isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: Spacing.md),
                        TextFormField(
                          controller: _prenomController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: Spacing.md),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: Spacing.md),
                        TextFormField(
                          controller: _societeController,
                          decoration: const InputDecoration(
                            labelText: 'Organisation',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        InkWell(
                          onTap: () => _pickDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de visite *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_month_rounded),
                            ),
                            child: Text(
                              '${_dateVisite.day.toString().padLeft(2, '0')}/'
                              '${_dateVisite.month.toString().padLeft(2, '0')}/'
                              '${_dateVisite.year}',
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
