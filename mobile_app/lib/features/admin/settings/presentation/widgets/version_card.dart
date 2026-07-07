import 'package:flutter/material.dart';

import '../../domain/entities/setting.dart';

class VersionCard extends StatelessWidget {
  final VersionInfo? version;
  final VoidCallback onTap;

  const VersionCard({super.key, required this.version, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: version == null ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Version',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (version == null)
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Charger'),
                    ),
                ],
              ),
              if (version != null) ...[
                const Divider(height: 24),
                _InfoRow(label: 'Application', value: version!.applicationVersion),
                const SizedBox(height: 8),
                _InfoRow(label: 'Backend', value: version!.backendVersion),
                const SizedBox(height: 8),
                _InfoRow(label: 'Environnement', value: version!.environment),
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
