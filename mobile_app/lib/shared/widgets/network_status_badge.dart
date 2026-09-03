import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_status_provider.dart';

class NetworkStatusBadge extends ConsumerWidget {
  final bool compact;

  const NetworkStatusBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider);

    final Color color;
    final String label;
    final IconData icon;

    if (!status.isOnline) {
      color = Colors.orange.shade800;
      icon = Icons.wifi_off_rounded;
      label = status.offlineQueueCount > 0
          ? 'Hors ligne (${status.offlineQueueCount} en attente)'
          : 'Hors ligne';
    } else if (status.isSyncing) {
      color = Colors.blue.shade700;
      icon = Icons.sync_rounded;
      label = 'Synchronisation...';
    } else if (status.offlineQueueCount > 0) {
      color = Colors.amber.shade900;
      icon = Icons.cloud_upload_rounded;
      label = '${status.offlineQueueCount} à synchroniser';
    } else {
      color = Colors.green.shade700;
      icon = Icons.wifi_rounded;
      label = 'En ligne';
    }

    if (compact) {
      return Tooltip(
        message: label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status.isSyncing)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                status.isOnline ? 'EN LIGNE' : 'HORS LIGNE',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (status.isOnline && status.offlineQueueCount > 0 && !status.isSyncing) {
          ref.read(networkStatusProvider.notifier).triggerAutoSync();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status.isSyncing)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
