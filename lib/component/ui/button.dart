import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../nesui_theme.dart';

enum IsIntent { primary, secondary, warning, danger, outline, plain }

enum IsSize { xs, sm, md, lg }

class NesuiButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  /// Layout
  final bool fullWidth;
  final bool loading;

  /// Variants
  final IsIntent intent;
  final IsSize size;
  final bool isCircle;

  const NesuiButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.fullWidth = false,
    this.loading = false,
    this.intent = IsIntent.primary,
    this.size = IsSize.md,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.nesui;
    final effectiveOnPressed = loading ? null : onPressed;

    final radius = isCircle ? 9999.0 : t.radius;

    final EdgeInsets padding = switch (size) {
      IsSize.xs => const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      IsSize.sm => const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      IsSize.md => const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      IsSize.lg => const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    };

    final double minHeight = switch (size) {
      IsSize.xs => 32,
      IsSize.sm => 36,
      IsSize.md => 44,
      IsSize.lg => 50,
    };

    final TextStyle textStyle = switch (size) {
      IsSize.xs => const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      IsSize.sm => const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      IsSize.md => const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      IsSize.lg => const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    };

    // ---- Colors (state-aware) ----
    Color bg(Set<MaterialState> states) {
      final disabled = states.contains(MaterialState.disabled);

      // Outline & plain are not filled
      if (intent == IsIntent.outline || intent == IsIntent.plain) {
        return Colors.transparent;
      }

      // Filled variants
      Color base = switch (intent) {
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

      if (intent == IsIntent.outline) {
        final c = t.brand;
        return disabled ? c.withOpacity(0.6) : c;
      }

      if (intent == IsIntent.plain) {
        final c = Theme.of(context).colorScheme.onSurface;
        return disabled ? c.withOpacity(0.6) : c;
      }

      if (intent == IsIntent.secondary) {
        final c = Theme.of(context).colorScheme.onSurface;
        return disabled ? c.withOpacity(0.6) : c;
      }

      // primary / warning / danger
      final c = Colors.white;
      return disabled ? c.withOpacity(0.75) : c;
    }

    BorderSide side(Set<MaterialState> states) {
      if (intent == IsIntent.outline) {
        final c = states.contains(MaterialState.disabled)
            ? t.border.withOpacity(0.7)
            : t.border;
        return BorderSide(color: c);
      }

      if (intent == IsIntent.secondary) {
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

    final content = _Content(
      loading: loading,
      child: child,
      color: MaterialStateProperty.resolveWith(
        fg,
      ).resolve(loading ? {MaterialState.disabled} : <MaterialState>{})!,
    );

    final Widget btn = switch (intent) {
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

    if (!fullWidth) return btn;
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
        SizedBox(width: 16, height: 16, child: RepeatRotateIcon()),

        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),

        const SizedBox(width: 10),
        child,
      ],
    );
  }
}

class RepeatRotateIcon extends StatefulWidget {
  const RepeatRotateIcon({super.key});

  @override
  State<RepeatRotateIcon> createState() => _RepeatRotateIconState();
}

class _RepeatRotateIconState extends State<RepeatRotateIcon> {
  int _tick = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_tick), // ganti key => animasi mulai ulang
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        onEnd: () => setState(() => _tick++), // repeat
        builder: (context, v, child) {
          return Transform.rotate(angle: v * 6.283185307179586, child: child);
        },
        child: const Icon(CupertinoIcons.slowmo, size: 16),
      ),
    );
  }
}
