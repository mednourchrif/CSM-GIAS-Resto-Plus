import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/services/qr_print_service.dart';
import '../../domain/entities/qr_code.dart';
import '../providers/qr_provider.dart';
import '../screens/qr_list_screen.dart';

class OwnerQrActions extends ConsumerWidget {
  final String ownerUuid;

  const OwnerQrActions({super.key, required this.ownerUuid});

  Future<QrCode?> _loadActiveQr(BuildContext context, WidgetRef ref) async {
    final history = await ref.read(qrProvider.notifier).getQrHistory(ownerUuid);
    if (!context.mounted) return null;

    QrCode? active;
    for (final qr in history ?? const <QrCode>[]) {
      if (qr.isActive) {
        active = qr;
        break;
      }
    }
    if (active == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun QR actif pour cet utilisateur.')),
      );
      return null;
    }

    final detailed = await ref.read(qrProvider.notifier).getQrCode(active.uuid);
    if (!context.mounted) return null;
    if (detailed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(qrProvider).error ?? 'Impossible de charger le QR.',
          ),
        ),
      );
    }
    return detailed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final qr = await _loadActiveQr(context, ref);
            if (qr != null && context.mounted) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QrDetailScreen(uuid: qr.uuid),
                ),
              );
            }
          },
          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
          label: const Text('Afficher'),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final qr = await _loadActiveQr(context, ref);
            if (qr != null) await QrPrintService.printQr(qr);
          },
          icon: const Icon(Icons.print_rounded, size: 18),
          label: const Text('Imprimer'),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final qr = await _loadActiveQr(context, ref);
            if (qr == null) return;
            final shared = await QrPrintService.shareQr(qr);
            if (context.mounted && !shared) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partage du QR annulé ou indisponible.'),
                ),
              );
            }
          },
          icon: const Icon(Icons.share_rounded, size: 18),
          label: const Text('Partager'),
        ),
      ],
    );
  }
}
