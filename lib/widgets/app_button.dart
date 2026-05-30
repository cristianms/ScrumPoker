import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final bool showProgress;
  final bool disabled;

  const AppButton(this.label, {super.key, this.onPressed, this.showProgress = false, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = !disabled && !showProgress;

    final Color primary = theme.colorScheme.primary;
    final Color primaryDeep = HSLColor.fromColor(primary).withLightness((HSLColor.fromColor(primary).lightness - 0.12).clamp(0.0, 1.0)).toColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(minHeight: kIsWeb ? 56 : 50, minWidth: kIsWeb ? 200 : 140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isEnabled ? LinearGradient(colors: [primary, primaryDeep], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: isEnabled ? null : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.45 : 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEnabled ? onPressed : null,
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: kIsWeb ? 18 : 14),
            child: Center(
              child: showProgress
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white70 : Colors.white)))
                  : Text(
                      label,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: isEnabled ? Colors.white : (isDark ? Colors.white38 : Colors.black38)),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
