import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdministrationButton extends StatelessWidget {
  const AdministrationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.push('/login'),
      icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
      label: const Text('Administration'),
    );
  }
}
