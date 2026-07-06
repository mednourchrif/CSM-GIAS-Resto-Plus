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
  const QrGenerateScreen({super.key});

  @override
  ConsumerState<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends ConsumerState<QrGenerateScreen> {
  String _ownerType = 'STAGIAIRE';
  bool _isGenerating = false;
  String? _selectedOwnerUuid;
  String? _selectedOwnerName;
  String? _generatedQrBase64;
  String? _generatedToken;

  @override
  void initState() {
    super.initState();
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
      _generatedToken = null;
    });

    QrCode? qr;
    if (_ownerType == 'STAGIAIRE') {
      final result = await ref.read(qrProvider.notifier).generateInternQr(_selectedOwnerUuid!);
      qr = result;
    } else {
      final result = await ref.read(qrProvider.notifier).generateVisitorQr(_selectedOwnerUuid!);
      qr = result;
    }

    if (!mounted) return;

    setState(() => _isGenerating = false);

    if (qr != null) {
      setState(() {
        _generatedQrBase64 = qr!.qrBase64;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(qrProvider).error ?? 'Erreur lors de la génération.'),
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
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Spacing.lg),
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
                    _selectedOwnerName = null;
                    _generatedQrBase64 = null;
                    _generatedToken = null;
                  });
                  _loadOwners();
                },
              ),
              const SizedBox(height: Spacing.md),
              Expanded(
                child: _ownerType == 'STAGIAIRE'
                    ? _buildInternList(theme, internState)
                    : _buildVisitorList(theme, visitorState),
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
                      borderRadius: BorderRadius.circular(2),
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
                    onPressed: _selectedOwnerUuid == null || _isGenerating ? null : _generate,
                    child: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
        child: Text('Aucun stagiaire actif.', style: theme.textTheme.bodyMedium),
      );
    }
    return ListView.separated(
      itemCount: interns.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
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
              style: TextStyle(
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
          trailing: selected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
          onTap: () {
            setState(() {
              _selectedOwnerUuid = intern.uuid;
              _selectedOwnerName = intern.fullName;
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
      separatorBuilder: (_, __) => const Divider(height: 1),
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
              style: TextStyle(
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
          trailing: selected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
          onTap: () {
            setState(() {
              _selectedOwnerUuid = visitor.uuid;
              _selectedOwnerName = visitor.fullName;
              _generatedQrBase64 = null;
            });
          },
        );
      },
    );
  }
}
