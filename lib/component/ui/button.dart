import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../nesui_theme.dart';

enum IsIntent { primary, secondary, warning, danger, outline, plain }

enum IsSize { xs, sm, md, lg }

@immutable
class NesuiButtonVariants {
  final IsIntent intent;
  final IsSize size;
  final bool isCircle;

  const NesuiButtonVariants({
    this.intent = IsIntent.primary,
    this.size = IsSize.md,
    this.isCircle = false,
  });

  NesuiButtonVariants copyWith({
    IsIntent? intent,
    IsSize? size,
    bool? isCircle,
  }) {
    return NesuiButtonVariants(
      intent: intent ?? this.intent,
      size: size ?? this.size,
      isCircle: isCircle ?? this.isCircle,
    );
  }
}

class NesuiButtonStyles {
  // defaultVariants: { intent: "primary", size: "md", isCircle: false }
  static const IsIntent defaultIntent = IsIntent.primary;
  static const IsSize defaultSize = IsSize.md;
  static const bool defaultIsCircle = false;

  static const NesuiButtonVariants defaultVariants = NesuiButtonVariants(
    intent: defaultIntent,
    size: defaultSize,
    isCircle: defaultIsCircle,
  );

  static ButtonStyle style(
    BuildContext context, {
    required NesuiButtonVariants variants,
    required bool disabled,
  }) {
    final t = context.nesui;

    final radius = variants.isCircle ? 9999.0 : t.radius;
    final padding = _padding(variants.size);
    final minHeight = _minHeight(variants.size);
    final textStyle = _textStyle(variants.size);

    Color bg(Set<MaterialState> states) {
      final isDisabled = disabled || states.contains(MaterialState.disabled);

      if (variants.intent == IsIntent.outline ||
          variants.intent == IsIntent.plain) {
        return Colors.transparent;
      }

      final Color base = switch (variants.intent) {
        IsIntent.primary => t.brand,
        IsIntent.secondary => Theme.of(context).colorScheme.surface,
        IsIntent.warning => const Color(0xFFF59E0B),
        IsIntent.danger => const Color(0xFFEF4444),
        _ => t.brand,
      };

      if (isDisabled) return base.withOpacity(0.5);
      if (states.contains(MaterialState.pressed)) return base.withOpacity(0.90);
      if (states.contains(MaterialState.hovered)) return base.withOpacity(0.95);
      return base;
    }

    Color fg(Set<MaterialState> states) {
      final isDisabled = disabled || states.contains(MaterialState.disabled);

      if (variants.intent == IsIntent.outline) {
        final c = t.brand;
        return isDisabled ? c.withOpacity(0.6) : c;
      }

      if (variants.intent == IsIntent.plain) {
        final c = Theme.of(context).colorScheme.onSurface;
        return isDisabled ? c.withOpacity(0.6) : c;
      }

      if (variants.intent == IsIntent.secondary) {
        final c = Theme.of(context).colorScheme.onSurface;
        return isDisabled ? c.withOpacity(0.6) : c;
      }

      final c = Colors.white;
      return isDisabled ? c.withOpacity(0.75) : c;
    }

    BorderSide side(Set<MaterialState> states) {
      final isDisabled = disabled || states.contains(MaterialState.disabled);

      if (variants.intent == IsIntent.outline) {
        final c = isDisabled ? t.border.withOpacity(0.7) : t.border;
        return BorderSide(color: c);
      }

      if (variants.intent == IsIntent.secondary) {
        final c = isDisabled ? t.border.withOpacity(0.6) : t.border;
        return BorderSide(color: c);
      }

      return BorderSide.none;
    }

    return ButtonStyle(
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
  }

  static EdgeInsets _padding(IsSize size) => switch (size) {
    IsSize.xs => const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    IsSize.sm => const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    IsSize.md => const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    IsSize.lg => const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  };

  static double _minHeight(IsSize size) => switch (size) {
    IsSize.xs => 32,
    IsSize.sm => 36,
    IsSize.md => 44,
    IsSize.lg => 50,
  };

  static TextStyle _textStyle(IsSize size) => switch (size) {
    IsSize.xs => const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    IsSize.sm => const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    IsSize.md => const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    IsSize.lg => const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  };
}

class NesuiButton extends StatefulWidget {
  // sync
  final VoidCallback? onPressed;

  // async (optional, button bisa self-loading)
  final Future<void> Function()? onPressedAsync;

  final Widget child;
  final Widget? loadingChild;

  final Widget? leading;
  final Widget? loadingLeading;

  final bool fullWidth;

  /// Controlled loading (kalau null => internal pending saat onPressedAsync)
  final bool? loading;

  final IsIntent intent;
  final IsSize size;
  final bool isCircle;

  const NesuiButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onPressedAsync,
    this.loadingChild,
    this.leading,
    this.loadingLeading,
    this.fullWidth = false,
    this.loading,

    // ✅ default aman (compile-time constant)
    this.intent = NesuiButtonStyles.defaultIntent,
    this.size = NesuiButtonStyles.defaultSize,
    this.isCircle = NesuiButtonStyles.defaultIsCircle,
  });

  @override
  State<NesuiButton> createState() => _NesuiButtonState();
}

class _NesuiButtonState extends State<NesuiButton> {
  bool _pending = false;

  bool get _isLoading => widget.loading ?? _pending;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    if (widget.onPressedAsync != null) {
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

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final variants = NesuiButtonVariants(
      intent: widget.intent,
      size: widget.size,
      isCircle: widget.isCircle,
    );

    final disabled =
        _isLoading ||
        (widget.onPressed == null && widget.onPressedAsync == null);

    final style = NesuiButtonStyles.style(
      context,
      variants: variants,
      disabled: disabled,
    );

    final Color fg =
        style.foregroundColor?.resolve(
          disabled ? {MaterialState.disabled} : <MaterialState>{},
        ) ??
        Theme.of(context).colorScheme.onSurface;

    final shownChild = _isLoading
        ? (widget.loadingChild ?? widget.child)
        : widget.child;

    final content = _Content(
      loading: _isLoading,
      child: shownChild,
      color: fg,
      leading: widget.leading,
      loadingLeading: widget.loadingLeading,
    );

    final onPressed = disabled ? null : _handlePress;

    final Widget btn = switch (widget.intent) {
      IsIntent.outline || IsIntent.secondary => OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: content,
      ),
      IsIntent.plain => TextButton(
        onPressed: onPressed,
        style: style,
        child: content,
      ),
      _ => FilledButton(onPressed: onPressed, style: style, child: content),
    };

    if (!widget.fullWidth) return btn;
    return SizedBox(width: double.infinity, child: btn);
  }
}

class _Content extends StatelessWidget {
  final bool loading;
  final Widget child;
  final Color color;

  final Widget? leading;
  final Widget? loadingLeading;

  const _Content({
    required this.loading,
    required this.child,
    required this.color,
    this.leading,
    this.loadingLeading,
  });

  @override
  Widget build(BuildContext context) {
    final Widget left = loading
        ? (loadingLeading ?? RepeatRotateIcon(color: color))
        : (leading ?? Icon(Icons.save, size: 16, color: color));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 16, height: 16, child: left),
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
