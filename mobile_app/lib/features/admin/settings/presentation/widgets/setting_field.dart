import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/localization/app_strings.dart';

import '../../domain/entities/setting.dart';

class SettingField extends StatelessWidget {
  final Setting setting;
  final String currentValue;
  final ValueChanged<String> onChanged;
  final bool isPending;

  const SettingField({
    super.key,
    required this.setting,
    required this.currentValue,
    required this.onChanged,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.settingLabel(setting.key, setting.label),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isPending)
              Container(
                margin: const EdgeInsetsDirectional.only(start: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  strings.modified,
                  style: const TextStyle(fontSize: 10, color: Colors.orange),
                ),
              ),
          ],
        ),
        if (setting.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              strings.settingDescription(setting.key, setting.description!),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label,
                const SizedBox(height: 8),
                _buildField(context),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: label),
              const SizedBox(width: 16),
              Expanded(child: _buildField(context)),
            ],
          );
        },
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
                ? TimeOfDay(
                    hour: int.tryParse(parts[0]) ?? 12,
                    minute: int.tryParse(parts[1]) ?? 0,
                  )
                : const TimeOfDay(hour: 12, minute: 0);
            final picked = await showTimePicker(
              context: context,
              initialTime: initial,
            );
            if (picked != null) {
              onChanged(
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
              );
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time_rounded, size: 20),
            ),
            child: Text(currentValue),
          ),
        );
      case 'select':
        final options = setting.options ?? [];
        if (currentValue.startsWith('[')) {
          final selected = (jsonDecode(currentValue) as List)
              .map((e) => e.toString())
              .toSet();
          return Wrap(
            spacing: 6,
            runSpacing: 4,
            children: options.map((opt) {
              final isSelected = selected.contains(opt);
              return FilterChip(
                label: Text(
                  AppStrings.of(context).settingOption(opt),
                  style: const TextStyle(fontSize: 12),
                ),
                selected: isSelected,
                onSelected: (sel) {
                  final updated = Set<String>.from(selected);
                  sel ? updated.add(opt) : updated.remove(opt);
                  final sorted = updated.toList()..sort();
                  onChanged('[${sorted.join(',')}]');
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          );
        }
        return InputDecorator(
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              isDense: true,
              isExpanded: true,
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(AppStrings.of(context).settingOption(opt)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        );
      case 'number':
        return TextFormField(
          initialValue: currentValue,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
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
}
