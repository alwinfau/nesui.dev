import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../nesui_theme.dart';

enum IsIntent { primary, secondary, warning, danger, outline, plain }

enum IsSize { xs, sm, md, lg }

class NesuiButton extends StatefulWidget {
  final VoidCallback? onPressed;

  /// Kalau ingin otomatis loading, pakai ini
  final Future<void> Function()? onPressedAsync;

  final Widget child;

  /// Child yang ditampilkan saat loading (mis. Text("Menyimpan..."))
  final Widget? loadingChild;

  /// Layout
  final bool fullWidth;

  /// Kalau diisi (true/false), button jadi "controlled" dari luar.
  /// Kalau null, button akan manage loading sendiri ketika onPressedAsync dipakai.
  final bool? loading;

  /// Variants
  final IsIntent intent;
  final IsSize size;
  final bool isCircle;

  const NesuiButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onPressedAsync,
    this.loadingChild,
    this.fullWidth = false,
    this.loading,
    this.intent = IsIntent.primary,
    this.size = IsSize.md,
    this.isCircle = false,
  });

  @override
  State<NesuiButton> createState() => _NesuiButtonState();
}

class _NesuiButtonState extends State<NesuiButton> {
  bool _pending = false;

  bool get _isLoading => widget.loading ?? _pending;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    // async mode
    if (widget.onPressedAsync != null) {
      // kalau controlled dari luar (widget.loading != null), jangan setState internal
      final canManageInternal = widget.loading == null;

      if (canManageInternal) setState(() => _pending = true);
      try {
        await widget.onPressedAsync!.call();
      } finally {
        if (!mounted) return;
        if (canManageInternal) setState(() => _pending = false);
      }
      return;
    }

    // sync mode
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.nesui;

    final effectiveOnPressed = _isLoading ? null : _handlePress;

    final radius = widget.isCircle ? 9999.0 : t.radius;

    final EdgeInsets padding = switch (widget.size) {
      IsSize.xs => const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      IsSize.sm => const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      IsSize.md => const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      IsSize.lg => const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    };

    final double minHeight = switch (widget.size) {
      IsSize.xs => 32,
      IsSize.sm => 36,
      IsSize.md => 44,
      IsSize.lg => 50,
    };

    final TextStyle textStyle = switch (widget.size) {
      IsSize.xs => const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      IsSize.sm => const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      IsSize.md => const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      IsSize.lg => const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    };

    Color bg(Set<MaterialState> states) {
      final disabled = states.contains(MaterialState.disabled);

      if (widget.intent == IsIntent.outline ||
          widget.intent == IsIntent.plain) {
        return Colors.transparent;
      }

      Color base = switch (widget.intent) {
        IsIntent.primary => t.brand,
        IsIntent.secondary => Theme.of(context).colorScheme.surface,
        IsIntent.warning => const Color(0xFFF59E0B),
        IsIntent.danger => const Color(0xFFEF4444),
        _ => t.brand,
      };

      if (disabled) return base.withOpacity(0.5);
      if (states.contains(MaterialState.pressed)) return base.withOpacity(0.90);
      if (states.contains(MaterialState.hovered)) return base.withOpacity(0.95);
      return base;
    }

    Color fg(Set<MaterialState> states) {
      final disabled = states.contains(MaterialState.disabled);

      if (widget.intent == IsIntent.outline) {
        final c = t.brand;
        return disabled ? c.withOpacity(0.6) : c;
      }

      if (widget.intent == IsIntent.plain) {
        final c = Theme.of(context).colorScheme.onSurface;
        return disabled ? c.withOpacity(0.6) : c;
      }

      if (widget.intent == IsIntent.secondary) {
        final c = Theme.of(context).colorScheme.onSurface;
        return disabled ? c.withOpacity(0.6) : c;
      }

      final c = Colors.white;
      return disabled ? c.withOpacity(0.75) : c;
    }

    BorderSide side(Set<MaterialState> states) {
      if (widget.intent == IsIntent.outline) {
        final c = states.contains(MaterialState.disabled)
            ? t.border.withOpacity(0.7)
            : t.border;
        return BorderSide(color: c);
      }

      if (widget.intent == IsIntent.secondary) {
        final c = states.contains(MaterialState.disabled)
            ? t.border.withOpacity(0.6)
            : t.border;
        return BorderSide(color: c);
      }

      return BorderSide.none;
    }

    final ButtonStyle style = ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, minHeight)),
      padding: MaterialStateProperty.all(padding),
      textStyle: MaterialStateProperty.all(textStyle),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      backgroundColor: MaterialStateProperty.resolveWith(bg),
      foregroundColor: MaterialStateProperty.resolveWith(fg),
      side: MaterialStateProperty.resolveWith(side),
    );

    final Color spinnerColor = MaterialStateProperty.resolveWith(
      fg,
    ).resolve(_isLoading ? {MaterialState.disabled} : <MaterialState>{})!;

    final Widget shownChild = _isLoading
        ? (widget.loadingChild ?? widget.child)
        : widget.child;

    final content = _Content(
      loading: _isLoading,
      child: shownChild,
      color: spinnerColor,
    );

    final Widget btn = switch (widget.intent) {
      IsIntent.outline || IsIntent.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: content,
      ),
      IsIntent.plain => TextButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: content,
      ),
      _ => FilledButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: content,
      ),
    };

    if (!widget.fullWidth) return btn;
    return SizedBox(width: double.infinity, child: btn);
  }
}

class _Content extends StatelessWidget {
  final bool loading;
  final Widget child;
  final Color color;

  const _Content({
    required this.loading,
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 16, height: 16, child: RepeatRotateIcon(color: color)),
        const SizedBox(width: 10),
        child,
      ],
    );
  }
}

class RepeatRotateIcon extends StatefulWidget {
  final Color color;
  const RepeatRotateIcon({super.key, required this.color});

  @override
  State<RepeatRotateIcon> createState() => _RepeatRotateIconState();
}

class _RepeatRotateIconState extends State<RepeatRotateIcon> {
  int _tick = 0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_tick),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      onEnd: () => setState(() => _tick++),
      builder: (context, v, child) {
        return Transform.rotate(angle: v * 6.283185307179586, child: child);
      },
      child: Icon(CupertinoIcons.slowmo, size: 16, color: widget.color),
    );
  }
}
