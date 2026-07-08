import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../providers/user_state.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String? _typeFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(adminUserProvider.notifier).refresh());
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
      ref.read(adminUserProvider.notifier).search(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminUserProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(adminUserProvider.notifier).refresh();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(
        onSave: (nom, prenom, email, password, type, roleId) async {
          final success = await ref.read(adminUserProvider.notifier).createUser(
                nom: nom,
                prenom: prenom,
                email: email,
                motDePasse: password,
                type: type,
                roleId: roleId,
              );
          if (success && mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditDialog(AdminUser user) {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(
        user: user,
        onSave: (nom, prenom, email, password, type, roleId) async {
          final success = await ref.read(adminUserProvider.notifier).updateUser(
                user.uuid,
                nom: nom,
                prenom: prenom,
                email: email,
                roleId: roleId,
              );
          if (success && mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showPasswordDialog(AdminUser user) {
    showDialog(
      context: context,
      builder: (_) => _PasswordResetDialog(
        user: user,
        onReset: (password) async {
          final success = await ref.read(adminUserProvider.notifier).resetPassword(
                user.uuid,
                password,
              );
          if (success && mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showDeleteConfirm(AdminUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer l\'utilisateur « ${user.fullName} » ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final success = await ref.read(adminUserProvider.notifier).deleteUser(user.uuid);
              if (success && mounted) Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showToggleStatusConfirm(AdminUser user) {
    final newStatus = user.isActive ? 'INACTIF' : 'ACTIF';
    final label = user.isActive ? 'désactiver' : 'activer';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${user.isActive ? 'Désactiver' : 'Activer'} l\'utilisateur'),
        content: Text(
          'Voulez-vous $label l\'utilisateur « ${user.fullName} » ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await ref.read(adminUserProvider.notifier).toggleStatus(
                    user.uuid,
                    newStatus,
                  );
              if (success && mounted) Navigator.of(context).pop();
            },
            child: Text(user.isActive ? 'Désactiver' : 'Activer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUserProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    ref.listen<AdminUserState>(adminUserProvider, (prev, next) {
      final notification = next.notification;
      if (notification == null) return;
      if (prev?.notification == notification) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(adminUserProvider.notifier).clearNotification();

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notification.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: notification.isError
                ? theme.colorScheme.error
                : Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(Spacing.md),
            duration: Duration(
              seconds: notification.isError ? 5 : 3,
            ),
            action: notification.isError
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        actions: [
          if (isDesktop)
            FilledButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(theme, state),
          Expanded(
            child: _buildBody(state, theme, isDesktop),
          ),
        ],
      ),
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: _showCreateDialog,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildFilters(ThemeData theme, AdminUserState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom, prénom ou email...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: _typeFilter == null,
                  onSelected: () {
                    setState(() => _typeFilter = null);
                    ref.read(adminUserProvider.notifier).setTypeFilter(null);
                  },
                ),
                const SizedBox(width: Spacing.xs),
                _FilterChip(
                  label: 'Administrateurs',
                  selected: _typeFilter == 'ADMINISTRATEUR',
                  onSelected: () {
                    setState(() => _typeFilter = 'ADMINISTRATEUR');
                    ref.read(adminUserProvider.notifier).setTypeFilter('ADMINISTRATEUR');
                  },
                ),
                const SizedBox(width: Spacing.xs),
                _FilterChip(
                  label: 'Réceptionnistes',
                  selected: _typeFilter == 'RECEPTION',
                  onSelected: () {
                    setState(() => _typeFilter = 'RECEPTION');
                    ref.read(adminUserProvider.notifier).setTypeFilter('RECEPTION');
                  },
                ),
                const SizedBox(width: Spacing.md),
                _StatusFilterDropdown(
                  value: _statusFilter,
                  onChanged: (v) {
                    setState(() => _statusFilter = v);
                    ref.read(adminUserProvider.notifier).setStatutFilter(v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminUserState state, ThemeData theme, bool isDesktop) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: theme.colorScheme.error),
              const SizedBox(height: Spacing.md),
              Text(state.error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: _onRefresh,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded,
                size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: Spacing.md),
            Text('Aucun utilisateur trouvé',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: Spacing.sm),
            Text('Ajoutez un administrateur ou réceptionniste.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: isDesktop
          ? _buildTable(state, theme)
          : _buildList(state, theme),
    );
  }

  Widget _buildList(AdminUserState state, ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(Spacing.md),
      itemCount: state.users.length + (state.hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= state.users.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final user = state.users[i];
        return _UserCard(
          user: user,
          onEdit: () => _showEditDialog(user),
          onToggleStatus: () => _showToggleStatusConfirm(user),
          onResetPassword: () => _showPasswordDialog(user),
          onDelete: () => _showDeleteConfirm(user),
        );
      },
    );
  }

  Widget _buildTable(AdminUserState state, ThemeData theme) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: DataTable(
        sortColumnIndex: 4,
        columns: [
          const DataColumn(label: Text('Nom')),
          const DataColumn(label: Text('Email')),
          const DataColumn(label: Text('Type')),
          const DataColumn(label: Text('Rôle')),
          DataColumn(
            label: const Text('Statut'),
            numeric: false,
          ),
          const DataColumn(label: Text('Dernière connexion')),
          const DataColumn(label: Text('Créé le')),
          const DataColumn(label: Text('Actions')),
        ],
        rows: state.users.map((user) {
          return DataRow(cells: [
            DataCell(Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w500))),
            DataCell(Text(user.email ?? '-')),
            DataCell(_TypeBadge(type: user.type)),
            DataCell(Text(user.roleName ?? '-')),
            DataCell(_StatusBadge(isActive: user.isActive)),
            DataCell(Text(_formatDate(user.derniereConnexion))),
            DataCell(Text(_formatDate(user.createdAt))),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  tooltip: 'Modifier',
                  onPressed: () => _showEditDialog(user),
                ),
                IconButton(
                  icon: Icon(
                    user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                    size: 18,
                    color: user.isActive ? Colors.orange : Colors.green,
                  ),
                  tooltip: user.isActive ? 'Désactiver' : 'Activer',
                  onPressed: () => _showToggleStatusConfirm(user),
                ),
                IconButton(
                  icon: const Icon(Icons.lock_reset_rounded, size: 18),
                  tooltip: 'Réinitialiser mot de passe',
                  onPressed: () => _showPasswordDialog(user),
                ),
                IconButton(
                  icon: Icon(Icons.delete_rounded, size: 18,
                      color: theme.colorScheme.error),
                  tooltip: 'Supprimer',
                  onPressed: () => _showDeleteConfirm(user),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// =========================================================================
// Filter Chip
// =========================================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = selected ? theme.colorScheme.primary : null;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onSelected(),
      visualDensity: VisualDensity.compact,
      selectedColor: chipColor?.withAlpha(25),
      checkmarkColor: chipColor,
    );
  }
}

// =========================================================================
// Status Filter Dropdown
// =========================================================================

class _StatusFilterDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _StatusFilterDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      value: value,
      hint: const Text('Statut', style: TextStyle(fontSize: 12)),
      isDense: true,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: null, child: Text('Tous', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(value: 'ACTIF', child: Text('Actif', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(value: 'INACTIF', child: Text('Désactivé', style: TextStyle(fontSize: 12))),
      ],
      onChanged: onChanged,
    );
  }
}

// =========================================================================
// User Card (mobile)
// =========================================================================

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onResetPassword,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: user.isAdmin
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.secondary.withValues(alpha: 0.15),
                  child: Icon(
                    user.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                    color: user.isAdmin ? AppColors.primary : AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600)),
                      if (user.email != null)
                        Text(user.email!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                _StatusBadge(isActive: user.isActive),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                _TypeBadge(type: user.type),
                if (user.roleName != null) ...[
                  const SizedBox(width: Spacing.sm),
                  Text(user.roleName!,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
            if (user.derniereConnexion != null) ...[
              const SizedBox(height: Spacing.xxs),
              Row(
                children: [
                  Icon(Icons.login_rounded, size: 12,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: Spacing.xxs),
                  Text('Dernière connexion: ${_formatDateTime(user.derniereConnexion!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  tooltip: 'Modifier',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                    size: 18,
                    color: user.isActive ? Colors.orange : Colors.green,
                  ),
                  tooltip: user.isActive ? 'Désactiver' : 'Activer',
                  onPressed: onToggleStatus,
                ),
                IconButton(
                  icon: const Icon(Icons.lock_reset_rounded, size: 18),
                  tooltip: 'Réinitialiser mot de passe',
                  onPressed: onResetPassword,
                ),
                IconButton(
                  icon: Icon(Icons.delete_rounded, size: 18,
                      color: theme.colorScheme.error),
                  tooltip: 'Supprimer',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// =========================================================================
// Status Badge
// =========================================================================

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isActive ? 'Actif' : 'Désactivé',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

// =========================================================================
// Type Badge
// =========================================================================

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isAdmin = type == 'ADMINISTRATEUR';
    final color = isAdmin ? AppColors.primary : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Réception',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }
}

// =========================================================================
// User Form Dialog (Create / Edit)
// =========================================================================

class _UserFormDialog extends StatefulWidget {
  final AdminUser? user;
  final Future<void> Function(String nom, String prenom, String email,
      String password, String type, int? roleId) onSave;

  const _UserFormDialog({this.user, required this.onSave});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  String _type = 'ADMINISTRATEUR';
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nomCtrl = TextEditingController(text: u?.nom ?? '');
    _prenomCtrl = TextEditingController(text: u?.prenom ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passwordCtrl = TextEditingController();
    if (u != null) _type = u.type;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await widget.onSave(
      _nomCtrl.text.trim(),
      _prenomCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _type,
      null,
    );
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEdit ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit) ...[
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ADMINISTRATEUR', child: Text('Administrateur')),
                      DropdownMenuItem(value: 'RECEPTION', child: Text('Réceptionniste')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _type = v);
                    },
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prenomCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Prénom *',
                          isDense: true,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: _nomCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nom *',
                          isDense: true,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                if (!isEdit) ...[
                  const SizedBox(height: Spacing.sm),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe *',
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: isEdit
                        ? null
                        : (v) {
                            if (v == null || v.length < 8) {
                              return 'Minimum 8 caractères';
                            }
                            return null;
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}

// =========================================================================
// Password Reset Dialog
// =========================================================================

class _PasswordResetDialog extends StatefulWidget {
  final AdminUser user;
  final Future<void> Function(String password) onReset;

  const _PasswordResetDialog({required this.user, required this.onReset});

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await widget.onReset(_passwordCtrl.text);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Réinitialiser le mot de passe'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Utilisateur: ${widget.user.fullName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe *',
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (v) {
                  if (v == null || v.length < 8) return 'Minimum 8 caractères';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Réinitialiser'),
        ),
      ],
    );
  }
}
