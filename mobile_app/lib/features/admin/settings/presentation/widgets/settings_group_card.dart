import 'package:flutter/material.dart';

import '../../domain/entities/setting.dart';
import 'setting_field.dart';

class SettingsGroupCard extends StatelessWidget {
  final SettingsGroup group;
  final Map<String, String> pendingChanges;
  final void Function(String, String) onChanged;

  const SettingsGroupCard({
    super.key,
    required this.group,
    required this.pendingChanges,
    required this.onChanged,
  });

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'restaurant': return Icons.restaurant_rounded;
      case 'recognition': return Icons.face_retouching_natural_rounded;
      case 'qr_codes': return Icons.qr_code_rounded;
      case 'application': return Icons.app_settings_alt_rounded;
      case 'security': return Icons.security_rounded;
      default: return Icons.settings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _categoryIcon(group.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  group.label,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 24),
            ...group.settings.map((setting) {
              final currentValue = pendingChanges[setting.key] ?? setting.value;
              return Column(
                children: [
                  SettingField(
                    setting: setting,
                    currentValue: currentValue,
                    onChanged: (value) => onChanged(setting.key, value),
                  ),
                  if (setting != group.settings.last)
                    const Divider(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
