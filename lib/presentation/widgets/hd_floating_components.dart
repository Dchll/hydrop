import 'package:flutter/material.dart';
import 'package:hydrop/presentation/widgets/hd_container.dart';

class HdFloatingAppBar extends StatelessWidget {
  const HdFloatingAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
    );

    return HdContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          if (bottom != null) ...[const SizedBox(height: 8), bottom!],
        ],
      ),
    );
  }
}

class HdFloatingIconButton extends StatelessWidget {
  const HdFloatingIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colorScheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.zero,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 21,
              color: onPressed == null
                  ? colorScheme.onSurface.withValues(alpha: 0.32)
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class HdSearchPill extends StatelessWidget {
  const HdSearchPill({super.key, required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      textField: true,
      label: hintText,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HdSearchField extends StatelessWidget {
  const HdSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );
  }
}
