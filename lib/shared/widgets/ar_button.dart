import 'package:flutter/material.dart';
import '../../features/ar/ar_page.dart';

class ARButton extends StatelessWidget {
  final double? size;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? tooltip;

  const ARButton({
    super.key,
    this.size = 40,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.tooltip = 'AR Experience',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'AR Experience',
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ARPage()));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: ARIconPainter(color: iconColor ?? Colors.black),
            size: Size(size!, size!),
          ),
        ),
      ),
    );
  }
}

class ARIconPainter extends CustomPainter {
  final Color color;

  ARIconPainter({this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final dashPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final cubeSize = size.width * 0.6;

    // Draw dashed border square
    _drawDashedRect(
      canvas,
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cubeSize * 1.2,
        height: cubeSize * 1.2,
      ),
      dashPaint,
    );

    // Draw 3D cube
    _draw3DCube(canvas, Offset(centerX, centerY), cubeSize * 0.6, paint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 3.0;
    const dashSpace = 2.0;

    // Top
    _drawDashedLine(
      canvas,
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      paint,
      dashWidth,
      dashSpace,
    );

    // Right
    _drawDashedLine(
      canvas,
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      paint,
      dashWidth,
      dashSpace,
    );

    // Bottom
    _drawDashedLine(
      canvas,
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
      paint,
      dashWidth,
      dashSpace,
    );

    // Left
    _drawDashedLine(
      canvas,
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.top),
      paint,
      dashWidth,
      dashSpace,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startT = i * (dashWidth + dashSpace) / distance;
      final endT = (i * (dashWidth + dashSpace) + dashWidth) / distance;

      final dashStart = Offset.lerp(start, end, startT)!;
      final dashEnd = Offset.lerp(start, end, endT)!;

      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _draw3DCube(Canvas canvas, Offset center, double size, Paint paint) {
    final halfSize = size / 2;

    // Define cube vertices
    final front = [
      Offset(center.dx - halfSize, center.dy - halfSize), // Top-left
      Offset(center.dx + halfSize, center.dy - halfSize), // Top-right
      Offset(center.dx + halfSize, center.dy + halfSize), // Bottom-right
      Offset(center.dx - halfSize, center.dy + halfSize), // Bottom-left
    ];

    final back = [
      Offset(center.dx - halfSize + 4, center.dy - halfSize + 4), // Top-left
      Offset(center.dx + halfSize + 4, center.dy - halfSize + 4), // Top-right
      Offset(
        center.dx + halfSize + 4,
        center.dy + halfSize + 4,
      ), // Bottom-right
      Offset(center.dx - halfSize + 4, center.dy + halfSize + 4), // Bottom-left
    ];

    // Draw back face
    canvas.drawLine(back[0], back[1], paint);
    canvas.drawLine(back[1], back[2], paint);
    canvas.drawLine(back[2], back[3], paint);
    canvas.drawLine(back[3], back[0], paint);

    // Draw front face
    canvas.drawLine(front[0], front[1], paint);
    canvas.drawLine(front[1], front[2], paint);
    canvas.drawLine(front[2], front[3], paint);
    canvas.drawLine(front[3], front[0], paint);

    // Draw connecting lines (perspective)
    canvas.drawLine(front[0], back[0], paint);
    canvas.drawLine(front[1], back[1], paint);
    canvas.drawLine(front[2], back[2], paint);
    canvas.drawLine(front[3], back[3], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Alternative simpler AR button using built-in icon
class SimpleARButton extends StatelessWidget {
  final double? size;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? tooltip;

  const SimpleARButton({
    super.key,
    this.size = 40,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.tooltip = 'AR Experience',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'AR Experience',
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ARPage()));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.view_in_ar, size: size! * 0.7, color: iconColor),
        ),
      ),
    );
  }
}
