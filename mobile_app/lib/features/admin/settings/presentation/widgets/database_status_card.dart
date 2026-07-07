import 'package:flutter/material.dart';

import '../../domain/entities/setting.dart';

class DatabaseStatusCard extends StatelessWidget {
  final DatabaseStatus? databaseStatus;
  final VoidCallback onTap;

  const DatabaseStatusCard({super.key, required this.databaseStatus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: databaseStatus == null ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.storage_rounded, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Base de données',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (databaseStatus == null)
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Charger'),
                    ),
                ],
              ),
              if (databaseStatus != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      databaseStatus!.isConnected ? Icons.check_circle_rounded : Icons.error_rounded,
                      size: 16,
                      color: databaseStatus!.isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      databaseStatus!.isConnected ? 'Connecté' : 'Déconnecté',
                      style: TextStyle(
                        color: databaseStatus!.isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Tables', value: '${databaseStatus!.totalTables}'),
                const SizedBox(height: 8),
                _InfoRow(label: 'Enregistrements', value: '${databaseStatus!.totalRecords}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}
