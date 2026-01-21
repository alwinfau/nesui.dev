import 'package:flutter/material.dart';
import '../nesui_theme.dart'; // lebih aman daripada package:nesui/...

enum NesuiIntent { brand, outline }

class NesuiButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool fullWidth;
  final bool loading;

  /// Intent = varian tampilan button (brand / outline)
  final NesuiIntent intent;

  const NesuiButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.fullWidth = false,
    this.loading = false,
    this.intent = NesuiIntent.brand,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.nesui;
    final effectiveOnPressed = loading ? null : onPressed;

    final Widget button = switch (intent) {
      NesuiIntent.brand => FilledButton(
        onPressed: effectiveOnPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return t.brand.withOpacity(0.5);
            }
            return t.brand;
          }),
          foregroundColor: MaterialStateProperty.all(t.onBrand),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(t.radius),
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        child: _Content(loading: loading, child: child, onBrand: t.onBrand),
      ),
      NesuiIntent.outline => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(t.brand),
          side: MaterialStateProperty.all(BorderSide(color: t.border)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(t.radius),
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        child: _Content(loading: loading, child: child, onBrand: t.brand),
      ),
    };

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class _Content extends StatelessWidget {
  final bool loading;
  final Widget child;
  final Color onBrand;

  const _Content({
    required this.loading,
    required this.child,
    required this.onBrand,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: onBrand),
        ),
        const SizedBox(width: 10),
        child,
      ],
    );
  }
}
