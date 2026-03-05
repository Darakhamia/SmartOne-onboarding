import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// SmartOne branded logo widget.
/// Renders "SMARTONE" wordmark + circular sparkle icon matching the brand identity.
class SmartOneLogo extends StatelessWidget {
  final double fontSize;
  final Color color;
  final bool showTagline;

  const SmartOneLogo({
    super.key,
    this.fontSize = 22,
    this.color = AppTheme.primary,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'SMARTONE',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
                height: 1,
              ),
            ),
            SizedBox(width: fontSize * 0.18),
            SizedBox(
              width: fontSize * 0.72,
              height: fontSize * 0.72,
              child: CustomPaint(painter: _SparklePainter(color: color)),
            ),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: fontSize * 0.22),
          Text(
            'Merchant Onboarding',
            style: TextStyle(
              fontSize: fontSize * 0.44,
              fontWeight: FontWeight.w400,
              color: color.withOpacity(0.55),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  const _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Circle outline
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.88,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.11,
    );

    // 4-pointed star inside
    final outerR = r * 0.48;
    final innerR = r * 0.16;
    const points = 4;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = i * math.pi / points - math.pi / 2;
      final rad = i.isEven ? outerR : innerR;
      final x = cx + rad * math.cos(angle);
      final y = cy + rad * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}
