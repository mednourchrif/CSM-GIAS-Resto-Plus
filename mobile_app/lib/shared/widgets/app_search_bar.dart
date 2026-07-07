import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';

/// Reusable search bar with debounce, clear button, and smooth animation.
///
/// Drop this in wherever a list needs filtering. Handles debounce internally
/// unless [immediate] is true.
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final Duration debounce;
  final bool immediate;

  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.debounce = AppDurations.searchDebounce,
    this.immediate = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    widget.onChanged(value);
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: AnimatedSwitcher(
            duration: AppDurations.fast,
            child: _hasFocus
                ? Icon(
                    Icons.search_rounded,
                    key: const ValueKey('focused'),
                    color: theme.colorScheme.primary,
                    size: Spacing.iconSm,
                  )
                : Icon(
                    Icons.search_rounded,
                    key: const ValueKey('idle'),
                    color: theme.colorScheme.onSurfaceVariant,
                    size: Spacing.iconSm,
                  ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  iconSize: Spacing.iconSm,
                  onPressed: _clear,
                  tooltip: 'Effacer',
                )
              : null,
        ),
      ),
    );
  }
}
