import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/setting.dart';

class SettingField extends StatelessWidget {
  final Setting setting;
  final String currentValue;
  final ValueChanged<String> onChanged;

  const SettingField({
    super.key,
    required this.setting,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isChanged = currentValue != setting.defaultValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        setting.label,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    if (isChanged)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Modifié',
                          style: TextStyle(fontSize: 10, color: Colors.orange),
                        ),
                      ),
                  ],
                ),
                if (setting.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      setting.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _buildField(context),
          ),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    switch (setting.fieldType) {
      case 'boolean':
        return Switch(
          value: currentValue.toLowerCase() == 'true',
          onChanged: (v) => onChanged(v.toString()),
        );
      case 'time':
        return InkWell(
          onTap: () async {
            final parts = currentValue.split(':');
            final initial = parts.length == 2
                ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 12, minute: int.tryParse(parts[1]) ?? 0)
                : const TimeOfDay(hour: 12, minute: 0);
            final picked = await showTimePicker(context: context, initialTime: initial);
            if (picked != null) {
              onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time_rounded, size: 20),
            ),
            child: Text(currentValue),
          ),
        );
      case 'select':
        return DropdownButtonFormField<String>(
          value: currentValue,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
          items: (setting.options ?? []).map((opt) {
            return DropdownMenuItem(value: opt, child: Text(_optionLabel(opt)));
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        );
      case 'number':
        return TextFormField(
          initialValue: currentValue,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        );
      default:
        return TextFormField(
          initialValue: currentValue,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        );
    }
  }

  String _optionLabel(String value) {
    switch (value) {
      case 'fr': return 'Français';
      case 'en': return 'Anglais';
      case 'ar': return 'Arabe';
      case 'light': return 'Clair';
      case 'dark': return 'Sombre';
      case 'system': return 'Système';
      case 'low': return 'Basse';
      case 'medium': return 'Moyenne';
      case 'high': return 'Haute';
      case 'L': return 'Faible';
      case 'M': return 'Moyenne';
      case 'Q': return 'Élevée';
      case 'H': return 'Maximale';
      case 'default': return 'Par défaut';
      case 'strict': return 'Stricte';
      case 'very_strict': return 'Très stricte';
      case '1': return 'Lundi';
      case '2': return 'Mardi';
      case '3': return 'Mercredi';
      case '4': return 'Jeudi';
      case '5': return 'Vendredi';
      case '6': return 'Samedi';
      case '7': return 'Dimanche';
      default: return value;
    }
  }
}
