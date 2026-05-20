import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Animated arc-gauge chart showing the AI probability score.
/// Uses only Flutter's Canvas — no external chart package needed.
class ProbabilityChart extends StatefulWidget {
  final double probability; // 0–100
  final double geminiProbability;
  final double groqProbability;
  final bool bothSuccess;

  const ProbabilityChart({
    super.key,
    required this.probability,
    required this.geminiProbability,
    required this.groqProbability,
    required this.bothSuccess,
  });

  @override
  State<ProbabilityChart> createState() => _ProbabilityChartState();
}

class _ProbabilityChartState extends State<ProbabilityChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ProbabilityChart old) {
    super.didUpdateWidget(old);
    if (old.probability != widget.probability) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color {
    if (widget.probability >= 70) return AppTheme.errorColor;
    if (widget.probability >= 40) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Gauge ──────────────────────────────────────────
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => CustomPaint(
            size: const Size(200, 120),
            painter: _GaugePainter(
              progress: (_anim.value * widget.probability) / 100,
              color: _color,
              isDark: isDark,
            ),
            child: SizedBox(
              height: 120,
              child: Align(
                alignment: const Alignment(0, 0.6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_anim.value * widget.probability).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _color,
                      ),
                    ),
                    Text(
                      'AI Probability',
                      style: TextStyle(
                        fontSize: 11,
                        color: _color.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Bar comparison (only when both APIs succeeded) ──
        if (widget.bothSuccess) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Model comparison',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          _ModelBar(
            label: 'Gemini',
            value: widget.geminiProbability,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          _ModelBar(
            label: 'Groq',
            value: widget.groqProbability,
            color: Colors.purple,
          ),
        ],
      ],
    );
  }
}

// ── Gauge painter ──────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color color;
  final bool isDark;

  const _GaugePainter(
      {required this.progress, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final radius = size.width / 2 - 14;

    const startAngle = math.pi; // 180°
    const sweepFull = math.pi; // 180°

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = color;

    final rect =
        Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    canvas.drawArc(rect, startAngle, sweepFull, false, trackPaint);
    // Fill
    canvas.drawArc(
        rect, startAngle, sweepFull * progress, false, fillPaint);

    // Tick marks at 0, 50, 100
    for (final pct in [0.0, 0.5, 1.0]) {
      final angle = startAngle + sweepFull * pct;
      final inner = Offset(
        cx + (radius - 10) * math.cos(angle),
        cy + (radius - 10) * math.sin(angle),
      );
      final outer = Offset(
        cx + (radius + 10) * math.cos(angle),
        cy + (radius + 10) * math.sin(angle),
      );
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color =
              (isDark ? Colors.white : Colors.black).withOpacity(0.18)
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}

// ── Animated horizontal bar for each model ─────────────────────────────────

class _ModelBar extends StatefulWidget {
  final String label;
  final double value; // 0–100
  final Color color;

  const _ModelBar(
      {required this.label, required this.value, required this.color});

  @override
  State<_ModelBar> createState() => _ModelBarState();
}

class _ModelBarState extends State<_ModelBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: widget.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_anim.value * widget.value) / 100,
                minHeight: 8,
                color: widget.color,
                backgroundColor: widget.color.withOpacity(0.12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${widget.value.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: widget.color,
          ),
        ),
      ],
    );
  }
}
