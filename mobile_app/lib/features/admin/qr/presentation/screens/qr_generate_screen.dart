import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../admin/interns/domain/entities/intern.dart';
import '../../../../admin/interns/presentation/providers/intern_provider.dart';
import '../../../../admin/visitors/domain/entities/visitor.dart';
import '../../../../admin/visitors/presentation/providers/visitor_provider.dart';
import '../../domain/entities/qr_code.dart';
import '../providers/qr_provider.dart';

class QrGenerateScreen extends ConsumerStatefulWidget {
  final String? initialOwnerType;
  final String? initialOwnerUuid;
  final String? initialOwnerName;

  const QrGenerateScreen({
    super.key,
    this.initialOwnerType,
    this.initialOwnerUuid,
    this.initialOwnerName,
  });

  @override
  ConsumerState<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends ConsumerState<QrGenerateScreen> {
  late String _ownerType;
  bool _isGenerating = false;
  String? _selectedOwnerUuid;
  String? _generatedQrBase64;

  @override
  void initState() {
    super.initState();
    _ownerType = widget.initialOwnerType ?? 'STAGIAIRE';
    _selectedOwnerUuid = widget.initialOwnerUuid;
    _loadOwners();
  }

  void _loadOwners() {
    if (_ownerType == 'STAGIAIRE') {
      ref.read(internProvider.notifier).refresh();
    } else {
      ref.read(visitorProvider.notifier).refresh();
    }
  }

  Future<void> _generate() async {
    if (_selectedOwnerUuid == null) return;

    setState(() {
      _isGenerating = true;
      _generatedQrBase64 = null;
    });

    QrCode? qr;
    if (_ownerType == 'STAGIAIRE') {
      final result = await ref
          .read(qrProvider.notifier)
          .generateInternQr(_selectedOwnerUuid!);
      qr = result;
    } else {
      final result = await ref
          .read(qrProvider.notifier)
          .generateVisitorQr(_selectedOwnerUuid!);
      qr = result;
    }

    if (!mounted) return;

    setState(() => _isGenerating = false);

    if (qr != null) {
      setState(() {
        _generatedQrBase64 = qr!.qrBase64;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code généré avec succès.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(qrProvider).error ?? 'Erreur lors de la génération.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final internState = ref.watch(internProvider);
    final visitorState = ref.watch(visitorProvider);

    return Dialog(
      insetPadding: const EdgeInsets.all(Spacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Générer un QR code',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              if (widget.initialOwnerUuid == null)
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'STAGIAIRE', label: Text('Stagiaire')),
                    ButtonSegment(value: 'VISITEUR', label: Text('Visiteur')),
                  ],
                  selected: {_ownerType},
                  onSelectionChanged: (v) {
                    setState(() {
                      _ownerType = v.first;
                      _selectedOwnerUuid = null;
                      _generatedQrBase64 = null;
                    });
                    _loadOwners();
                  },
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.person_outline_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(widget.initialOwnerName ?? 'Bénéficiaire'),
                  subtitle: Text(
                    _ownerType == 'STAGIAIRE' ? 'Stagiaire' : 'Visiteur',
                  ),
                ),
              const SizedBox(height: Spacing.md),
              if (widget.initialOwnerUuid == null)
                Expanded(
                  child: _ownerType == 'STAGIAIRE'
                      ? _buildInternList(theme, internState)
                      : _buildVisitorList(theme, visitorState),
                )
              else
                Text(
                  'Le QR précédent sera révoqué automatiquement. '
                  'Remettez uniquement le nouveau code à la personne concernée.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: Spacing.md),
              if (_generatedQrBase64 != null) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.radiusXs),
                      child: Image.memory(
                        base64Decode(
                          _generatedQrBase64!.contains(',')
                              ? _generatedQrBase64!.split(',').last
                              : _generatedQrBase64!,
                        ),
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                  const SizedBox(width: Spacing.sm),
                  FilledButton(
                    onPressed: _selectedOwnerUuid == null || _isGenerating
                        ? null
                        : _generate,
                    child: _isGenerating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Générer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInternList(ThemeData theme, dynamic state) {
    final interns = state.interns as List<Intern>;
    if (state.isLoading && interns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (interns.isEmpty) {
      return Center(
        child: Text(
          'Aucun stagiaire actif.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      itemCount: interns.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final intern = interns[index];
        final selected = _selectedOwnerUuid == intern.uuid;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: Text(
              '${intern.prenom[0]}${intern.nom[0]}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          title: Text(intern.fullName),
          subtitle: Text(intern.matricule),
          selected: selected,
          trailing: selected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
          onTap: () {
            setState(() {
              _selectedOwnerUuid = intern.uuid;
              _generatedQrBase64 = null;
            });
          },
        );
      },
    );
  }

  Widget _buildVisitorList(ThemeData theme, dynamic state) {
    final visitors = state.visitors as List<Visitor>;
    if (state.isLoading && visitors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (visitors.isEmpty) {
      return Center(
        child: Text('Aucun visiteur actif.', style: theme.textTheme.bodyMedium),
      );
    }
    return ListView.separated(
      itemCount: visitors.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        final selected = _selectedOwnerUuid == visitor.uuid;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: Text(
              '${visitor.prenom[0]}${visitor.nom[0]}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          title: Text(visitor.fullName),
          subtitle: Text(visitor.societe ?? visitor.formattedDate),
          selected: selected,
          trailing: selected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
          onTap: () {
            setState(() {
              _selectedOwnerUuid = visitor.uuid;
              _generatedQrBase64 = null;
            });
          },
        );
      },
    );
  }
}
