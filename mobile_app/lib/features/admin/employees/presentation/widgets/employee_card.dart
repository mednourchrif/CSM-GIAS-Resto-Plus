import 'package:flutter/material.dart';

import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/employee.dart';
import 'employee_status_badge.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const EmployeeCard({super.key, required this.employee, required this.onTap});

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF0D6E6E),
      const Color(0xFF4B6587),
      const Color(0xFF7B1FA2),
      const Color(0xFF0277BD),
      const Color(0xFF2E7D32),
      const Color(0xFFE8683A),
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = _avatarColor(employee.nom);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              // Avatar with initials
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      avatarColor,
                      avatarColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: Center(
                  child: Text(
                    '${employee.prenom.isNotEmpty ? employee.prenom[0] : '?'}'
                    '${employee.nom.isNotEmpty ? employee.nom[0] : '?'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              // Name & matricule
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      employee.matricule,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              // Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  EmployeeStatusBadge(status: employee.statut),
                  const SizedBox(height: Spacing.xxs + 1),
                  EmployeeStatusBadge(status: employee.statutEnrolement),
                ],
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: Spacing.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
