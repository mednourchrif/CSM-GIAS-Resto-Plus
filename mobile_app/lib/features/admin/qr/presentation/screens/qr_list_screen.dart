import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/services/download_service.dart';
import '../../../../../shared/widgets/detail_row.dart';
import '../../domain/entities/qr_code.dart';
import '../providers/qr_provider.dart';
import '../providers/qr_state.dart';
import '../widgets/qr_card.dart';
import 'qr_generate_screen.dart';

class QrListScreen extends ConsumerStatefulWidget {
  const QrListScreen({super.key});

  @override
  ConsumerState<QrListScreen> createState() => _QrListScreenState();
}

class _QrListScreenState extends ConsumerState<QrListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String? _typeFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(qrProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(qrProvider.notifier).search(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(qrProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(qrProvider.notifier).refresh();
  }

  void _showDetail(String uuid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _QrDetailScreen(uuid: uuid),
      ),
    );
  }

  void _showGenerateDialog() {
    showDialog(
      context: context,
      builder: (_) => const QrGenerateScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Codes'),
        actions: [
          if (isDesktop)
            FilledButton.icon(
              onPressed: _showGenerateDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Générer'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, UUID ou type...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: _typeFilter == null && _statusFilter == null,
                  onSelected: () {
                    setState(() {
                      _typeFilter = null;
                      _statusFilter = null;
                    });
                    ref.read(qrProvider.notifier).setTypeFilter(null);
                    ref.read(qrProvider.notifier).setStatusFilter(null);
                  },
                ),
                const SizedBox(width: Spacing.sm),
                _FilterChip(
                  label: 'Stagiaires',
                  selected: _typeFilter == 'STAGIAIRE',
                  onSelected: () {
                    setState(() => _typeFilter = 'STAGIAIRE');
                    ref.read(qrProvider.notifier).setTypeFilter('STAGIAIRE');
                  },
                ),
                const SizedBox(width: Spacing.sm),
                _FilterChip(
                  label: 'Visiteurs',
                  selected: _typeFilter == 'VISITEUR',
                  onSelected: () {
                    setState(() => _typeFilter = 'VISITEUR');
                    ref.read(qrProvider.notifier).setTypeFilter('VISITEUR');
                  },
                ),
                const SizedBox(width: Spacing.md),
                _FilterChip(
                  label: 'Actifs',
                  selected: _statusFilter == 'ACTIF',
                  color: Colors.green,
                  onSelected: () {
                    setState(() => _statusFilter = 'ACTIF');
                    ref.read(qrProvider.notifier).setStatusFilter('ACTIF');
                  },
                ),
                const SizedBox(width: Spacing.sm),
                _FilterChip(
                  label: 'Expirés',
                  selected: _statusFilter == 'EXPIRE',
                  color: Colors.red,
                  onSelected: () {
                    setState(() => _statusFilter = 'EXPIRE');
                    ref.read(qrProvider.notifier).setStatusFilter('EXPIRE');
                  },
                ),
                const SizedBox(width: Spacing.sm),
                _FilterChip(
                  label: 'Révoqués',
                  selected: _statusFilter == 'REVOQUE',
                  color: Colors.orange,
                  onSelected: () {
                    setState(() => _statusFilter = 'REVOQUE');
                    ref.read(qrProvider.notifier).setStatusFilter('REVOQUE');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Expanded(
            child: _buildBody(state, theme, isDesktop),
          ),
        ],
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
              onPressed: _showGenerateDialog,
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildBody(QrState state, ThemeData theme, bool isDesktop) {
    if (state.isLoading && state.qrCodes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.qrCodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: Spacing.md),
              Text(state.error!, textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: Spacing.lg),
              FilledButton(onPressed: _onRefresh, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    if (state.qrCodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2_rounded, size: 64,
                  color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: Spacing.md),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'Aucun QR code trouvé pour "${state.searchQuery}"'
                    : 'Aucun QR code',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return _buildDataTable(state, theme);
    }

    return _buildCardList(state);
  }

  Widget _buildCardList(QrState state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: state.qrCodes.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.qrCodes.length) {
            return const Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final qr = state.qrCodes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child:             QrCard(qrCode: qr, onTap: () => _showDetail(qr.uuid)),
          );
        },
      ),
    );
  }

  Widget _buildDataTable(QrState state, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          DataTable(
            sortColumnIndex: 0,
            headingRowHeight: 48,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 64,
            columns: const [
              DataColumn(label: Text('Propriétaire')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Statut')),
              DataColumn(label: Text('Expiration')),
              DataColumn(label: Text('Validations')),
            ],
            rows: state.qrCodes.map((qr) {
              return DataRow(
                onSelectChanged: (_) => _showDetail(qr.uuid),
                cells: [
                  DataCell(Text(qr.proprietaireFullName)),
                  DataCell(Text(qr.typeLabel)),
                  DataCell(QrStatusBadge(status: qr.statut)),
                  DataCell(Text(
                    '${qr.dateExpiration.day.toString().padLeft(2, '0')}/'
                    '${qr.dateExpiration.month.toString().padLeft(2, '0')}/'
                    '${qr.dateExpiration.year}',
                  )),
                  DataCell(Text('${qr.nombreValidations}')),
                ],
              );
            }).toList(),
          ),
          if (state.hasMore)
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = selected ? (color ?? Theme.of(context).colorScheme.primary) : null;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor?.withAlpha(25),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: selected ? chipColor : null,
        fontWeight: selected ? FontWeight.w600 : null,
      ),
    );
  }
}

// ---- Detail Screen ----

class _QrDetailScreen extends ConsumerStatefulWidget {
  final String uuid;

  const _QrDetailScreen({required this.uuid});

  @override
  ConsumerState<_QrDetailScreen> createState() => _QrDetailScreenState();
}

class _QrDetailScreenState extends ConsumerState<_QrDetailScreen> {
  QrCode? _qrCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final qr = await ref.read(qrProvider.notifier).getQrCode(widget.uuid);
    if (mounted) {
      setState(() {
        _qrCode = qr;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('QR Code')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final qr = _qrCode;
    if (qr == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('QR Code')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64,
                  color: theme.colorScheme.error),
              const SizedBox(height: 16),
              const Text('Impossible de charger le QR code.'),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        actions: [
          if (qr.isActive)
            PopupMenuButton<String>(
              onSelected: (v) => _handleAction(context, ref, qr, v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'download', child: Text('Télécharger')),
                const PopupMenuItem(value: 'print', child: Text('Imprimer')),
                const PopupMenuItem(value: 'regenerate', child: Text('Régénérer')),
                const PopupMenuItem(
                  value: 'revoke',
                  child: Text('Révoquer', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildQrImage(qr, theme),
              const SizedBox(height: Spacing.lg),
              Text(
                qr.proprietaireFullName,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                qr.typeLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              QrStatusBadge(status: qr.statut),
              const SizedBox(height: Spacing.xxl),
              DetailRow(label: 'UUID', value: qr.uuid),
              DetailRow(label: 'Type', value: qr.typeLabel),
              DetailRow(label: 'Expiration', value: _formatDate(qr.dateExpiration)),
              DetailRow(label: 'Validations', value: '${qr.nombreValidations}'),
              if (qr.createdAt != null)
                DetailRow(label: 'Créé le', value: _formatDateTime(qr.createdAt!)),
              if (qr.dateRevocation != null)
                DetailRow(label: 'Révoqué le', value: _formatDateTime(qr.dateRevocation!)),
              if (qr.motifRevocation != null)
                DetailRow(label: 'Motif', value: qr.motifRevocation!),
              if (qr.derniereValidation != null)
                DetailRow(
                  label: 'Dernière validation',
                  value: _formatDateTime(qr.derniereValidation!),
                ),
              const SizedBox(height: Spacing.xxl),
              if (qr.isActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _handleAction(context, ref, qr, 'download'),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Télécharger'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleAction(context, ref, qr, 'print'),
                        icon: const Icon(Icons.print_rounded),
                        label: const Text('Imprimer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleAction(context, ref, qr, 'regenerate'),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Régénérer'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleAction(context, ref, qr, 'revoke'),
                        icon: const Icon(Icons.block_rounded),
                        label: const Text('Révoquer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrImage(QrCode qr, ThemeData theme) {
    final base64 = qr.qrBase64;
    if (base64 != null && base64.isNotEmpty) {
      try {
        final raw = base64.contains(',') ? base64.split(',').last : base64;
        final bytes = base64Decode(raw);
        return Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Image.memory(
              bytes,
              width: 240,
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _qrPlaceholder(theme),
            ),
          ),
        );
      } catch (_) {
        return _qrPlaceholder(theme);
      }
    }
    return _qrPlaceholder(theme);
  }

  Widget _qrPlaceholder(ThemeData theme) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Icon(
        Icons.qr_code_2_rounded,
        size: 120,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, QrCode qr, String action) {
    switch (action) {
      case 'download':
        _download(context, qr);
      case 'print':
        _showPrintPreview(context, qr.uuid);
      case 'regenerate':
        _confirmRegenerate(context, ref, qr);
      case 'revoke':
        _confirmRevoke(context, ref, qr);
    }
  }

  Future<void> _download(BuildContext context, QrCode qr) async {
    final base64 = qr.qrBase64;
    if (base64 == null || base64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image QR disponible.')),
      );
      return;
    }

    final safeName = qr.proprietaireFullName.replaceAll(RegExp(r'\s+'), '');
    final fileName = 'QR_${safeName}_${qr.uuid.substring(0, 8)}.png';
    final path = await DownloadService.saveQrToDownloads(
      fileName: fileName,
      base64Image: base64,
    );

    if (!context.mounted) return;

    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR sauvegardé: $path'),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sauvegarde du QR.')),
      );
    }
  }

  void _showPrintPreview(BuildContext context, String uuid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PrintPreviewScreen(uuid: uuid),
      ),
    );
  }

  void _confirmRegenerate(BuildContext context, WidgetRef ref, QrCode qr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Régénérer le QR code'),
        content: Text(
          'Le QR code actif de ${qr.proprietaireFullName} sera révoqué '
          'et un nouveau sera généré. Poursuivre ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final newQr = await ref.read(qrProvider.notifier).regenerateQr(
                    qr.proprietaireUuid,
                    ownerType: qr.typeProprietaire,
                  );
              if (context.mounted) {
                if (newQr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR code régénéré avec succès.')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(qrProvider).error ?? 'Erreur lors de la régénération.',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Régénérer'),
          ),
        ],
      ),
    );
  }

  void _confirmRevoke(BuildContext context, WidgetRef ref, QrCode qr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Révoquer le QR code'),
        content: const Text(
          'Ce QR code deviendra immédiatement inutilisable. Poursuivre ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(qrProvider.notifier).revokeQr(qr.uuid);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR code révoqué.')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(qrProvider).error ?? 'Erreur lors de la révocation.',
                      ),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Révoquer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ---- Print Preview Screen ----

class _PrintPreviewScreen extends ConsumerStatefulWidget {
  final String uuid;

  const _PrintPreviewScreen({required this.uuid});

  @override
  ConsumerState<_PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends ConsumerState<_PrintPreviewScreen> {
  QrCode? _qrCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final qr = await ref.read(qrProvider.notifier).getQrCode(widget.uuid);
    if (mounted) {
      setState(() {
        _qrCode = qr;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aperçu impression')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final qr = _qrCode;
    if (qr == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aperçu impression')),
        body: Center(child: const Text('Impossible de charger le QR code.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu impression'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Imprimer',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impression à venir.')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(Spacing.lg),
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (qr.qrBase64 != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    base64Decode(
                      qr.qrBase64!.contains(',')
                          ? qr.qrBase64!.split(',').last
                          : qr.qrBase64!,
                    ),
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.qr_code_2_rounded,
                      size: 100,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 100,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              const SizedBox(height: Spacing.md),
              Text(
                qr.proprietaireFullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                qr.typeLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'UUID: ${qr.uuid}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                _formatDate(qr.dateExpiration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return 'Expire le ${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
