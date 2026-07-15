import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../../audit/domain/entities/audit_log.dart';
import '../../../audit/domain/repositories/audit_repository.dart';
import '../../../audit/presentation/providers/audit_provider.dart';

class AuditLogListScreen extends ConsumerStatefulWidget {
  const AuditLogListScreen({super.key});

  @override
  ConsumerState<AuditLogListScreen> createState() => _AuditLogListScreenState();
}

class _AuditLogListScreenState extends ConsumerState<AuditLogListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  AuditQueryParams _params = const AuditQueryParams();
  bool _showFilters = false;

  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  String? _filterRole;
  String? _filterAction;
  String? _filterEntityType;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final current = ref.read(auditLogsProvider(_params));

    current.whenData((response) {
      if (response.hasMore) {
        setState(() {
          _params = _params.copyWith(page: _params.page + 1);
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _params = _params.copyWith(page: 1, search: query.isNotEmpty ? query : null, clearSearch: query.isEmpty);
    });
  }

  void _applyFilters() {
    setState(() {
      _params = _params.copyWith(
        page: 1,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
        role: _filterRole,
        action: _filterAction,
        entityType: _filterEntityType,
        status: _filterStatus,
        clearDateFrom: _filterDateFrom == null,
        clearDateTo: _filterDateTo == null,
        clearRole: _filterRole == null,
        clearAction: _filterAction == null,
        clearEntityType: _filterEntityType == null,
        clearStatus: _filterStatus == null,
      );
      _showFilters = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _filterDateFrom = null;
      _filterDateTo = null;
      _filterRole = null;
      _filterAction = null;
      _filterEntityType = null;
      _filterStatus = null;
      _params = const AuditQueryParams();
      _showFilters = false;
    });
  }

  Future<void> _onExport() async {
    final result = await showModalBottomSheet<ExportFormat>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                'Exporter les logs',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: AppColors.success),
              title: const Text('CSV'),
              onTap: () => Navigator.of(ctx).pop(ExportFormat.csv),
            ),
            ListTile(
              leading: const Icon(Icons.grid_on_rounded, color: AppColors.info),
              title: const Text('Excel'),
              onTap: () => Navigator.of(ctx).pop(ExportFormat.excel),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
              title: const Text('PDF'),
              onTap: () => Navigator.of(ctx).pop(ExportFormat.pdf),
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;

    _doExport(result);
  }

  Future<void> _doExport(ExportFormat format) async {
    final repo = ref.read(auditRepositoryProvider);
    final result = await repo.exportAuditLogs(
      dateFrom: _params.dateFrom,
      dateTo: _params.dateTo,
      role: _params.role,
      action: _params.action,
      entityType: _params.entityType,
      status: _params.status,
      search: _params.search,
    );

    result.when(
      success: (items) async {
        final content = _buildExportContent(items, format);
        final dir = await getTemporaryDirectory();
        final ext = switch (format) {
          ExportFormat.csv => 'csv',
          ExportFormat.excel => 'xlsx',
          ExportFormat.pdf => 'pdf',
        };
        final file = File('${dir.path}/audit_logs.${DateTime.now().millisecondsSinceEpoch}.$ext');
        await file.writeAsString(content);

        if (!mounted) return;
        await Share.shareXFiles([XFile(file.path)], text: 'Logs d\'audit');
      },
      failure: (f) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  String _buildExportContent(List<AuditLogExportItem> items, ExportFormat format) {
    final buf = StringBuffer();
    buf.writeln('Timestamp;Utilisateur;Rôle;Action;Entité;Statut;Description');
    for (final item in items) {
      final ts = DateFormat('yyyy-MM-dd HH:mm:ss').format(item.timestamp);
      final desc = (item.description ?? '').replaceAll('"', '""');
      buf.writeln('$ts;${item.userName};${item.userRole};${item.action};${item.entityName ?? ''};${item.status};"$desc"');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= Spacing.tabletBreakpoint;
    final logsAsync = ref.watch(auditLogsProvider(_params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs d\'audit'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off_rounded : Icons.filter_alt_rounded),
            tooltip: 'Filtres',
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            tooltip: 'Exporter',
            onPressed: _onExport,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, Spacing.xs),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par utilisateur, entité, description...',
                prefixIcon: const Icon(Icons.search_rounded, size: Spacing.iconSm),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: Spacing.iconSm),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_showFilters)
            _buildFilterPanel(theme),
          Expanded(
            child: logsAsync.when(
              loading: () => isDesktop ? const ShimmerDataTable() : const ShimmerList(),
              error: (err, _) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.invalidate(auditLogsProvider(_params)),
              ),
              data: (response) {
                if (response.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.history_rounded,
                    title: _params.search != null || _params.action != null
                        ? 'Aucun résultat'
                        : 'Aucun log d\'audit',
                  );
                }
                if (isDesktop) {
                  return _buildDataTable(context, response);
                }
                return _buildCardList(context, response);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtres', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              _filterChip(
                label: _filterDateFrom != null
                    ? 'Du: ${DateFormat('dd/MM/yy').format(_filterDateFrom!)}'
                    : 'Date début',
                onSelected: (_) => _pickDate(context, isFrom: true),
              ),
              _filterChip(
                label: _filterDateTo != null
                    ? 'Au: ${DateFormat('dd/MM/yy').format(_filterDateTo!)}'
                    : 'Date fin',
                onSelected: (_) => _pickDate(context, isFrom: false),
              ),
              _filterDropdown<String>(
                theme: theme,
                value: _filterRole,
                label: 'Rôle',
                items: const ['ADMIN', 'RECEPTION', 'SYSTEM', 'EMPLOYE'],
                onChanged: (v) => setState(() => _filterRole = v),
              ),
              _filterDropdown<String>(
                theme: theme,
                value: _filterAction,
                label: 'Action',
                items: const [
                  'LOGIN_SUCCESS', 'LOGOUT',
                  'EMPLOYEE_CREATED', 'EMPLOYEE_UPDATED', 'EMPLOYEE_DELETED',
                  'VISITOR_CREATED', 'VISITOR_UPDATED', 'VISITOR_DELETED',
                  'INTERN_CREATED', 'INTERN_UPDATED', 'INTERN_DELETED',
                  'USER_CREATED', 'USER_UPDATED', 'USER_DELETED',
                  'USER_PASSWORD_CHANGED', 'USER_ACTIVATED', 'USER_DEACTIVATED',
                  'QR_GENERATED', 'QR_DOWNLOADED', 'QR_PRINTED', 'FACE_ENROLLED',
                  'MEAL_REGISTERED', 'SETTINGS_UPDATED', 'SETTINGS_RESET',
                ],
                onChanged: (v) => setState(() => _filterAction = v),
              ),
              _filterDropdown<String>(
                theme: theme,
                value: _filterStatus,
                label: 'Statut',
                items: const ['SUCCESS', 'FAILURE'],
                onChanged: (v) => setState(() => _filterStatus = v),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _resetFilters, child: const Text('Réinitialiser')),
              const SizedBox(width: Spacing.sm),
              FilledButton(onPressed: _applyFilters, child: const Text('Appliquer')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required void Function(bool)? onSelected}) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: false,
      onSelected: onSelected,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _filterDropdown<T>({
    required ThemeData theme,
    required T? value,
    required String label,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Spacing.radiusSm)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString(), style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _filterDateFrom = picked;
        } else {
          _filterDateTo = picked.add(const Duration(days: 1));
        }
      });
    }
  }

  Widget _buildCardList(BuildContext context, AuditLogListResponse response) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _params = _params.copyWith(page: 1));
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: response.items.length + (response.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == response.items.length) {
            return const Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _AuditLogCard(
            log: response.items[index],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _AuditLogDetailScreen(log: response.items[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, AuditLogListResponse response) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        DataTable(
          sortColumnIndex: 0,
          sortAscending: false,
          columns: const [
            DataColumn(label: Text('Date/Heure')),
            DataColumn(label: Text('Utilisateur')),
            DataColumn(label: Text('Rôle')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Statut')),
            DataColumn(label: Text('Description')),
          ],
          rows: response.items.map((log) {
            return DataRow(
              onSelectChanged: (_) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _AuditLogDetailScreen(log: log),
                ),
              ),
              cells: [
                DataCell(Text(
                  DateFormat('dd/MM/yy HH:mm').format(log.timestamp),
                  style: const TextStyle(fontSize: 12),
                )),
                DataCell(Text(log.userName)),
                DataCell(_roleChip(log.userRole)),
                DataCell(_actionChip(log.action)),
                DataCell(_statusChip(log.status)),
                DataCell(SizedBox(
                  width: 300,
                  child: Text(
                    log.description ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )),
              ],
            );
          }).toList(),
        ),
        if (response.hasMore)
          const Padding(
            padding: EdgeInsets.all(Spacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _roleChip(String role) {
    final (Color color, String label) = switch (role.toUpperCase()) {
      'ADMIN' => (AppColors.primary, 'Admin'),
      'RECEPTION' => (AppColors.warning, 'Réception'),
      'SYSTEM' => (AppColors.info, 'Système'),
      _ => (AppColors.outline, role),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionChip(String action) {
    final config = _actionConfig(action);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.$1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(config.$2, style: TextStyle(fontSize: 11, color: config.$1, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusChip(String status) {
    final (Color color, String label) = switch (status.toUpperCase()) {
      'SUCCESS' => (AppColors.success, 'Succès'),
      'FAILURE' => (AppColors.error, 'Échec'),
      _ => (AppColors.outline, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  (Color, String) _actionConfig(String action) {
    switch (action) {
      case 'LOGIN_SUCCESS':
      case 'LOGIN_FAILURE':
        return (AppColors.info, action == 'LOGIN_SUCCESS' ? 'Connexion' : 'Échec connexion');
      case 'LOGOUT':
        return (AppColors.outline, 'Déconnexion');
      case 'EMPLOYEE_CREATED':
      case 'VISITOR_CREATED':
      case 'INTERN_CREATED':
      case 'USER_CREATED':
        return (const Color(0xFF0277BD), 'Création');
      case 'EMPLOYEE_UPDATED':
      case 'VISITOR_UPDATED':
      case 'INTERN_UPDATED':
      case 'USER_UPDATED':
        return (const Color(0xFFE67E22), 'Modification');
      case 'EMPLOYEE_DELETED':
      case 'VISITOR_DELETED':
      case 'INTERN_DELETED':
      case 'USER_DELETED':
      case 'FACE_REMOVED':
        return (AppColors.error, 'Suppression');
      case 'EMPLOYEE_ACTIVATED':
      case 'USER_ACTIVATED':
        return (AppColors.success, 'Activé');
      case 'EMPLOYEE_DEACTIVATED':
      case 'USER_DEACTIVATED':
        return (AppColors.warning, 'Désactivé');
      case 'QR_GENERATED':
      case 'QR_DOWNLOADED':
      case 'QR_PRINTED':
        return (const Color(0xFF4B6587), 'QR Code');
      case 'FACE_ENROLLED':
      case 'FACE_REENROLLED':
        return (AppColors.info, 'Visage');
      case 'MEAL_REGISTERED':
        return (AppColors.success, 'Repas');
      case 'SETTINGS_UPDATED':
      case 'SETTINGS_RESET':
        return (const Color(0xFFE67E22), 'Paramètres');
      case 'USER_PASSWORD_CHANGED':
        return (AppColors.warning, 'Mot de passe');
      default:
        return (AppColors.outline, action);
    }
  }
}

enum ExportFormat { csv, excel, pdf }

class _AuditLogCard extends StatelessWidget {
  final AuditLog log;
  final VoidCallback onTap;

  const _AuditLogCard({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yy HH:mm').format(log.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  _statusChipSmall(log.status, theme),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                log.userName,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Spacing.xs),
              Row(
                children: [
                  _roleChipSmall(log.userRole, theme),
                  const SizedBox(width: Spacing.sm),
                  _actionChipSmall(log.action, theme),
                ],
              ),
              if (log.description != null && log.description!.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  log.description!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChipSmall(String status, ThemeData theme) {
    final color = status == 'SUCCESS' ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status == 'SUCCESS' ? 'Succès' : 'Échec',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _roleChipSmall(String role, ThemeData theme) {
    final color = switch (role.toUpperCase()) {
      'ADMIN' => AppColors.primary,
      'RECEPTION' => AppColors.warning,
      'SYSTEM' => AppColors.info,
      _ => AppColors.outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(role, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionChipSmall(String action, ThemeData theme) {
    final (Color color, String label) = switch (action) {
      'LOGIN_SUCCESS' => (AppColors.info, 'Connexion'),
      'LOGIN_FAILURE' => (AppColors.error, 'Échec connexion'),
      'LOGOUT' => (AppColors.outline, 'Déconnexion'),
      String a when a.endsWith('_CREATED') => (const Color(0xFF0277BD), 'Création'),
      String a when a.endsWith('_UPDATED') => (const Color(0xFFE67E22), 'Modification'),
      String a when a.endsWith('_DELETED') || a == 'FACE_REMOVED' => (AppColors.error, 'Suppression'),
      'MEAL_REGISTERED' => (AppColors.success, 'Repas'),
      'SETTINGS_UPDATED' || 'SETTINGS_RESET' => (const Color(0xFFE67E22), 'Paramètres'),
      'FACE_ENROLLED' || 'FACE_REENROLLED' => (AppColors.info, 'Visage'),
      'QR_GENERATED' || 'QR_DOWNLOADED' || 'QR_PRINTED' => (const Color(0xFF4B6587), 'QR Code'),
      _ => (AppColors.outline, action),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _AuditLogDetailScreen extends StatelessWidget {
  final AuditLog log;

  const _AuditLogDetailScreen({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du log')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Informations générales', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Divider(),
                      _detailRow(theme, 'Date/Heure', DateFormat('dd/MM/yyyy HH:mm:ss').format(log.timestamp)),
                      _detailRow(theme, 'Utilisateur', log.userName),
                      _detailRow(theme, 'Rôle', log.userRole),
                      _detailRow(theme, 'Action', log.action),
                      _detailRow(theme, 'Statut', log.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Divider(),
                      Text(log.description ?? 'Aucune description', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Requête HTTP', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Divider(),
                      _detailRow(theme, 'Méthode', log.httpMethod ?? '-'),
                      _detailRow(theme, 'Endpoint', log.endpoint ?? '-'),
                      _detailRow(theme, 'Adresse IP', log.ipAddress ?? '-'),
                      _detailRow(theme, 'User-Agent', log.userAgent ?? '-'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entité', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Divider(),
                      _detailRow(theme, 'Type', log.entityType ?? '-'),
                      _detailRow(theme, 'UUID', log.entityUuid ?? '-'),
                      _detailRow(theme, 'Nom', log.entityName ?? '-'),
                    ],
                  ),
                ),
              ),
              if (log.metadataJson != null && log.metadataJson!.isNotEmpty) ...[
                const SizedBox(height: Spacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Métadonnées', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const Divider(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Spacing.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(Spacing.radiusSm),
                          ),
                          child: SelectableText(
                            log.metadataJson!,
                            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
