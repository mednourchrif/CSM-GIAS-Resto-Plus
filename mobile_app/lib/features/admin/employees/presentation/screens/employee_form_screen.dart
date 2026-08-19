import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/employee_creation.dart';
import '../../../qr/domain/entities/qr_code.dart';
import '../../../../../shared/services/qr_print_service.dart';
import '../providers/employee_provider.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _matriculeController;
  String _statut = 'ACTIF';
  bool _isSaving = false;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nomController = TextEditingController(text: e?.nom ?? '');
    _prenomController = TextEditingController(text: e?.prenom ?? '');
    _matriculeController = TextEditingController(text: e?.matricule ?? '');
    _statut = e?.statut ?? 'ACTIF';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    bool success;
    EmployeeCreation? creation;
    if (_isEditing) {
      success = await ref
          .read(employeeProvider.notifier)
          .updateEmployee(
            widget.employee!.uuid,
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            matricule: _matriculeController.text.trim(),
            statut: _statut,
          );
    } else {
      creation = await ref
          .read(employeeProvider.notifier)
          .createEmployee(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            matricule: _matriculeController.text.trim(),
            statut: _statut,
          );
      success = creation != null;
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      if (creation != null) {
        await _showGeneratedQr(creation.qrCode);
        if (!mounted) return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Employé modifié avec succès.'
                : 'Employé créé avec succès.',
          ),
        ),
      );
    } else {
      final error = ref.read(employeeProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Une erreur est survenue.')),
      );
    }
  }

  Future<void> _showGeneratedQr(QrCode qr) {
    final encoded = qr.qrBase64;
    final bytes = encoded == null
        ? null
        : base64Decode(
            encoded.contains(',') ? encoded.split(',').last : encoded,
          );
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 42,
        ),
        title: const Text('Employé et QR créés'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Le visage reste optionnel et peut être enrôlé plus tard.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.md),
                if (bytes != null)
                  Image.memory(
                    bytes,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(height: Spacing.sm),
                Text(
                  '${_prenomController.text.trim()} ${_nomController.text.trim()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Matricule : ${_matriculeController.text.trim()}'),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () => QrPrintService.printQr(qr),
            icon: const Icon(Icons.print_rounded),
            label: const Text('Imprimer'),
          ),
          OutlinedButton.icon(
            onPressed: () => QrPrintService.shareQr(qr),
            icon: const Icon(Icons.share_rounded),
            label: const Text('Partager'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isEditing ? 'Modifier l\'employé' : 'Nouvel employé';

    return Dialog(
      insetPadding: const EdgeInsets.all(Spacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
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
                          validator: (v) => Validators.required(
                            v,
                            fieldName: 'Le nom',
                          )?.message,
                        ),
                        const SizedBox(height: Spacing.md),
                        TextFormField(
                          controller: _prenomController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => Validators.required(
                            v,
                            fieldName: 'Le prénom',
                          )?.message,
                        ),
                        const SizedBox(height: Spacing.md),
                        TextFormField(
                          controller: _matriculeController,
                          decoration: const InputDecoration(
                            labelText: 'Matricule *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => Validators.required(
                            v,
                            fieldName: 'Le matricule',
                          )?.message,
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
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: Spacing.sm,
                  overflowSpacing: Spacing.xs,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
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
