import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Time-of-day theme
// ─────────────────────────────────────────────────────────────────────────────

enum _DayPhase { dawn, day, dusk, night }

class _SceneTheme {
  const _SceneTheme({
    required this.skyTop,
    required this.skyBot,
    required this.groundTint,
    required this.hillColor,
    required this.treeColor,
    required this.cloudColor,
    required this.inkAlpha,
  });

  final Color skyTop;
  final Color skyBot;
  final Color groundTint;
  final Color hillColor;
  final Color treeColor;
  final Color cloudColor;
  final double inkAlpha;

  static const dawn = _SceneTheme(
    skyTop:      Color(0xFFFBCFE8),
    skyBot:      Color(0xFFFEF3C7),
    groundTint:  Color(0xFFD1FAE5),
    hillColor:   Color(0xFF6EE7B7),
    treeColor:   Color(0xFF065F46),
    cloudColor:  Color(0xFFFFF7ED),
    inkAlpha:    0.75,
  );

  static const day = _SceneTheme(
    skyTop:      Color(0xFFBAE6FD),
    skyBot:      Color(0xFFE0F2FE),
    groundTint:  Color(0xFFBBF7D0),
    hillColor:   Color(0xFF6EE7B7),
    treeColor:   Color(0xFF064E3B),
    cloudColor:  Color(0xFFFFFFFF),
    inkAlpha:    0.87,
  );

  static const dusk = _SceneTheme(
    skyTop:      Color(0xFFF97316),
    skyBot:      Color(0xFFE879F9),
    groundTint:  Color(0xFFFDE68A),
    hillColor:   Color(0xFF78350F),
    treeColor:   Color(0xFF431407),
    cloudColor:  Color(0xFFFED7AA),
    inkAlpha:    0.70,
  );

  static const night = _SceneTheme(
    skyTop:      Color(0xFF0F172A),
    skyBot:      Color(0xFF1E1B4B),
    groundTint:  Color(0xFF1E3A5F),
    hillColor:   Color(0xFF1E3A5F),
    treeColor:   Color(0xFF0F1E35),
    cloudColor:  Color(0xFF334155),
    inkAlpha:    0.55,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class WalkingStudentPainter extends CustomPainter {
  const WalkingStudentPainter({
    required this.walkPhase,
    required this.scrollPhase,
    required this.isRefreshing,
    required this.hour,
  });

  final double walkPhase;
  final double scrollPhase;
  final bool isRefreshing;
  final int hour;

  static const _ink   = Color(0xFF1A1A2E);
  static const _shirt = Color(0xFFA78BFA);
  static const _skin  = Color(0xFFFFCBA4);
  static const _hair  = Color(0xFF5B3A1E);
  static const _pants = Color(0xFF374151);
  static const _shoe  = Color(0xFF1F2937);
  static const _bag   = Color(0xFFC4B5FD);

  _DayPhase get _phase {
    if (hour >= 5 && hour < 8)  return _DayPhase.dawn;
    if (hour >= 8 && hour < 17) return _DayPhase.day;
    if (hour >= 17 && hour < 21) return _DayPhase.dusk;
    return _DayPhase.night;
  }

  _SceneTheme get _theme {
    switch (_phase) {
      case _DayPhase.dawn:  return _SceneTheme.dawn;
      case _DayPhase.day:   return _SceneTheme.day;
      case _DayPhase.dusk:  return _SceneTheme.dusk;
      case _DayPhase.night: return _SceneTheme.night;
    }
  }

  bool get _isNight => _phase == _DayPhase.night;
  double get _horizonFrac => 0.74;

  @override
  void paint(Canvas canvas, Size size) {
    final theme = _theme;
    _paintSky(canvas, size, theme);
    if (_isNight) _paintStars(canvas, size);
    _paintCelestialBody(canvas, size);
    _paintFarHills(canvas, size, theme);
    _paintClouds(canvas, size, theme);
    _paintMidTrees(canvas, size, theme);
    _paintGround(canvas, size, theme);
    _paintFencePosts(canvas, size, theme);
    if (isRefreshing) _paintRefreshCrowd(canvas, size);
    _paintGrass(canvas, size, theme);
    _paintStudent(canvas, size, theme);
  }

  void _paintSky(Canvas canvas, Size size, _SceneTheme t) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.skyTop, t.skyBot],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const seeds = [
      (0.08, 0.05), (0.18, 0.12), (0.32, 0.04), (0.45, 0.15),
      (0.55, 0.08), (0.67, 0.03), (0.74, 0.17), (0.83, 0.07),
      (0.91, 0.13), (0.12, 0.20), (0.38, 0.22), (0.62, 0.25),
      (0.25, 0.10), (0.50, 0.02), (0.78, 0.22), (0.95, 0.18),
    ];
    final gy = size.height * _horizonFrac;
    for (final (fx, fy) in seeds) {
      final x = fx * size.width;
      final y = fy * gy;
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(walkPhase * 4 * math.pi + fx * 30));
      final r = (0.8 + fx * 1.2).clamp(0.8, 2.0);
      canvas.drawCircle(Offset(x, y), r, paint..color = Colors.white.withValues(alpha: twinkle));
    }
  }

  void _paintCelestialBody(Canvas canvas, Size size) {
    final gy = size.height * _horizonFrac;
    if (_isNight) {
      _paintMoon(canvas, size, gy);
    } else {
      _paintSun(canvas, size, gy);
    }
  }

  void _paintSun(Canvas canvas, Size size, double gy) {
    final clampedHour = hour.clamp(5, 17).toDouble();
    final angle = (clampedHour - 5) / 12.0 * math.pi;
    final sx = size.width * (1.0 - (clampedHour - 5) / 12.0);
    final sy = gy - math.sin(angle) * gy * 0.72;
    canvas.drawCircle(Offset(sx, sy), 22,
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.35));
    canvas.drawCircle(Offset(sx, sy), 14,
        Paint()..color = const Color(0xFFFBBF24));
    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.65)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      const r1 = 18.0;
      const r2 = 26.0;
      canvas.drawLine(
        Offset(sx + math.cos(a) * r1, sy + math.sin(a) * r1),
        Offset(sx + math.cos(a) * r2, sy + math.sin(a) * r2),
        rayPaint,
      );
    }
  }

  void _paintMoon(Canvas canvas, Size size, double gy) {
    double h = hour.toDouble();
    if (h < 9) h += 24;
    final t = ((h - 21) / 12.0).clamp(0.0, 1.0);
    final angle = t * math.pi;
    final mx = size.width * (1.0 - t);
    final my = gy - math.sin(angle) * gy * 0.65;
    canvas.drawCircle(Offset(mx, my), 20,
        Paint()..color = const Color(0xFFE0E7FF).withValues(alpha: 0.18));
    canvas.drawCircle(Offset(mx, my), 13,
        Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawCircle(Offset(mx + 7, my - 3), 11,
        Paint()..color = _theme.skyTop..blendMode = BlendMode.srcOver);
    final craterPaint = Paint()..color = const Color(0xFFCBD5E1).withValues(alpha: 0.45);
    canvas.drawCircle(Offset(mx - 4, my + 2), 2.2, craterPaint);
    canvas.drawCircle(Offset(mx - 1, my - 4), 1.4, craterPaint);
  }

  void _paintFarHills(Canvas canvas, Size size, _SceneTheme t) {
    final gy = size.height * _horizonFrac;
    final offset = scrollPhase * size.width * 0.8;
    final fill = Paint()..color = t.hillColor.withValues(alpha: _isNight ? 0.55 : 0.45);
    const tileW = 1.0;
    for (var i = -1; i <= 3; i++) {
      final cx = (i * size.width * tileW - offset % (size.width * tileW));
      _drawHill(canvas, cx + size.width * 0.25, gy, size.width * 0.38, gy * 0.28, fill);
      _drawHill(canvas, cx + size.width * 0.70, gy, size.width * 0.30, gy * 0.18, fill);
    }
  }

  void _drawHill(Canvas canvas, double cx, double gy, double width, double height, Paint fill) {
    final path = Path()
      ..moveTo(cx - width / 2, gy)
      ..quadraticBezierTo(cx, gy - height, cx + width / 2, gy)
      ..close();
    canvas.drawPath(path, fill);
  }

  void _paintClouds(Canvas canvas, Size size, _SceneTheme t) {
    final fill   = Paint()..color = t.cloudColor.withValues(alpha: _isNight ? 0.35 : 0.90);
    final stroke = Paint()
      ..color = _ink.withValues(alpha: _isNight ? 0.05 : 0.09)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    const clouds = [
      (0.12, 0.12, 0.18, 1.00),
      (0.52, 0.05, 0.10, 0.62),
      (0.78, 0.18, 0.28, 0.82),
    ];
    for (final (bx, fy, speed, scale) in clouds) {
      final x = ((bx - scrollPhase * speed) % 1.1) * size.width;
      _drawCloud(canvas, x, size.height * fy, 24.0 * scale, fill, stroke);
    }
  }

  void _drawCloud(Canvas canvas, double cx, double cy, double r, Paint fill, Paint stroke) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.58))
      ..addOval(Rect.fromCircle(center: Offset(cx - r * 0.52, cy + r * 0.20), radius: r * 0.42))
      ..addOval(Rect.fromCircle(center: Offset(cx + r * 0.52, cy + r * 0.20), radius: r * 0.42))
      ..addOval(Rect.fromCircle(center: Offset(cx + r * 0.22, cy + r * 0.30), radius: r * 0.48));
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _paintMidTrees(Canvas canvas, Size size, _SceneTheme t) {
    final gy = size.height * _horizonFrac;
    final offset = scrollPhase * size.width * 1.6;
    const tileW = 0.5;
    for (var i = -1; i <= 4; i++) {
      final tx = (i * size.width * tileW - offset % (size.width * tileW));
      _drawTree(canvas, tx + size.width * 0.10, gy, 30, t);
      _drawTree(canvas, tx + size.width * 0.32, gy, 24, t);
    }
  }

  void _drawTree(Canvas canvas, double x, double gy, double h, _SceneTheme t) {
    canvas.drawRect(Rect.fromLTWH(x - 3, gy - h, 6, h * 0.40),
        Paint()..color = t.treeColor.withValues(alpha: 0.70));
    final foliage = Paint()..color = t.treeColor.withValues(alpha: _isNight ? 0.60 : 0.85);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x, gy - h * 0.68), width: h * 0.55, height: h * 0.50),
        foliage);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x, gy - h * 0.90), width: h * 0.38, height: h * 0.36),
        foliage);
  }

  void _paintGround(Canvas canvas, Size size, _SceneTheme t) {
    final gy = size.height * _horizonFrac;
    canvas.drawRect(Rect.fromLTRB(0, gy, size.width, size.height),
        Paint()..color = t.groundTint.withValues(alpha: _isNight ? 0.50 : 0.30));
    final lp = Paint()
      ..color = _ink.withValues(alpha: _isNight ? 0.15 : 0.22)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final hp = Path()..moveTo(0, gy);
    for (double x = 0; x <= size.width; x += 6) {
      hp.lineTo(x, gy + 0.7 * math.sin(x * 0.09 + 1.4));
    }
    canvas.drawPath(hp, lp);
  }

  void _paintFencePosts(Canvas canvas, Size size, _SceneTheme t) {
    final gy = size.height * _horizonFrac;
    final offset = scrollPhase * size.width * 3.2;
    const spacing = 0.18;
    final postPaint = Paint()
      ..color = (_isNight ? const Color(0xFF334155) : const Color(0xFF92400E))
          .withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final strokeP = Paint()
      ..color = _ink.withValues(alpha: _isNight ? 0.20 : 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (var i = -1; i <= 7; i++) {
      final px = (i * size.width * spacing - offset % (size.width * spacing));
      const postH = 22.0;
      const postW = 5.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(px - postW / 2, gy - postH, postW, postH),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, postPaint);
      canvas.drawRRect(rect, strokeP);
      if (i < 7) {
        final nextPx = ((i + 1) * size.width * spacing - offset % (size.width * spacing));
        canvas.drawLine(Offset(px + postW / 2, gy - postH * 0.70),
            Offset(nextPx - postW / 2, gy - postH * 0.70),
            strokeP..strokeWidth = 0.9);
        canvas.drawLine(Offset(px + postW / 2, gy - postH * 0.35),
            Offset(nextPx - postW / 2, gy - postH * 0.35),
            strokeP..strokeWidth = 0.9);
      }
    }
  }

  void _paintGrass(Canvas canvas, Size size, _SceneTheme t) {
    final gy = size.height * _horizonFrac;
    final grassColor = _isNight
        ? const Color(0xFF1D4ED8).withValues(alpha: 0.35)
        : const Color(0xFF10B981).withValues(alpha: 0.48);
    final gp = Paint()
      ..color = grassColor
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final offset = scrollPhase * size.width * 1.8;
    const spacing = 0.12;
    for (var i = -1; i <= 9; i++) {
      final gx = (i * size.width * spacing - offset % (size.width * spacing));
      final sway = 0.18 * math.sin(scrollPhase * 2 * math.pi + i * 1.5);
      for (var j = -1; j <= 1; j++) {
        final bx = gx + j * 3.5;
        canvas.drawLine(Offset(bx, gy), Offset(bx + (sway + j * 0.1) * 5.5, gy - 7.5), gp);
      }
    }
  }

  // ── Walking student ───────────────────────────────────────────────────────

  void _paintStudent(Canvas canvas, Size size, _SceneTheme t) {
    final inkAlpha = t.inkAlpha;
    final gy = size.height * _horizonFrac;
    final cx = size.width * 0.44;
    final tt = walkPhase * 2 * math.pi;
    final s2 = math.sin(tt) * math.sin(tt);
    final bodyRise = 3.5 * s2;
    final scX = 1.0 + 0.038 * (1 - s2);
    final scY = 1.0 - 0.038 * (1 - s2);
    final lagT    = (walkPhase - 0.06).clamp(0.0, 1.0) * 2 * math.pi;
    final bagSway = 3.8 * math.sin(lagT);
    final hairLag = 2.8 * math.sin(lagT + 0.4);
    final headBob = 1.3 * math.sin(2 * tt);
    const legAmp   = 0.660;
    const armAmp   = 0.470;
    const kneeAmp  = 0.44;
    const elbowAmp = 0.28;
    final rLeg   =  legAmp  * math.sin(tt);
    final lLeg   = -legAmp  * math.sin(tt);
    final rArm   = -armAmp  * math.sin(tt);
    final lArm   =  armAmp  * math.sin(tt);
    final rKnee  = kneeAmp  * math.max(0.0,  math.sin(tt));
    final lKnee  = kneeAmp  * math.max(0.0, -math.sin(tt));
    final rElbow = elbowAmp * math.max(0.0, -math.sin(tt));
    final lElbow = elbowAmp * math.max(0.0,  math.sin(tt));
    const hr    = 11.5;
    const tH    = 22.0;
    const tW    = 13.0;
    const neckH = 4.5;
    const uArmL = 12.5;
    const lArmL = 11.0;
    const uLegL = 19.5;
    const lLegL = 16.5;
    const footL = 8.0;
    final feetY     = gy - bodyRise;
    final hipY      = feetY - 23.0;
    final shoulderY = hipY - tH * scY;
    final headCY    = shoulderY - neckH - hr;
    final ink = Paint()
      ..color      = _ink.withValues(alpha: inkAlpha)
      ..strokeWidth = 1.85
      ..strokeCap  = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style      = PaintingStyle.stroke;
    final fill = Paint()..style = PaintingStyle.fill;
    _drawLeg(canvas, cx, hipY, rLeg, rKnee, uLegL, lLegL, footL,
             isFront: false, ink: ink, fill: fill, inkAlpha: inkAlpha);
    _drawArm(canvas, cx, shoulderY, tW, rArm, rElbow, uArmL, lArmL,
             isFront: false, ink: ink, fill: fill, inkAlpha: inkAlpha);
    _drawBackpack(canvas, cx, shoulderY, tH * scY, bagSway, ink, fill, inkAlpha);
    _drawTorso(canvas, cx, shoulderY, hipY, tW * scX, tH * scY, ink, fill, inkAlpha);
    _drawLeg(canvas, cx, hipY, lLeg, lKnee, uLegL, lLegL, footL,
             isFront: true,  ink: ink, fill: fill, inkAlpha: inkAlpha);
    _drawArm(canvas, cx, shoulderY, tW, lArm, lElbow, uArmL, lArmL,
             isFront: true,  ink: ink, fill: fill, inkAlpha: inkAlpha);
    _drawHead(canvas, cx, headCY, hr, headBob, hairLag, ink, fill, inkAlpha);
  }

  void _drawLeg(Canvas canvas, double cx, double hipY,
      double angle, double kneeBend, double uLen, double lLen, double fLen,
      {required bool isFront, required Paint ink, required Paint fill, required double inkAlpha}) {
    final hx = cx + (isFront ? 1.5 : -1.5);
    final hy = hipY;
    final kx = hx + math.sin(angle) * uLen;
    final ky = hy + math.cos(angle) * uLen;
    final la = angle - kneeBend;
    final ax = kx + math.sin(la) * lLen;
    final ay = ky + math.cos(la) * lLen;
    final a  = isFront ? 1.0 : 0.62;
    fill.color = _pants.withValues(alpha: a);
    canvas.drawPath(Path()
      ..moveTo(hx - 3.8, hy) ..lineTo(kx - 2.8, ky)
      ..lineTo(ax - 2.2, ay) ..lineTo(ax + 2.2, ay)
      ..lineTo(kx + 2.8, ky) ..lineTo(hx + 3.8, hy)
      ..close(), fill);
    ink ..color = _ink.withValues(alpha: isFront ? inkAlpha : inkAlpha * 0.60)
        ..strokeWidth = isFront ? 1.85 : 1.40;
    canvas.drawLine(Offset(hx, hy), Offset(kx, ky), ink);
    canvas.drawLine(Offset(kx, ky), Offset(ax, ay), ink);
    fill.color = _shoe.withValues(alpha: a);
    canvas.save();
    canvas.translate(ax, ay);
    canvas.rotate(-la * 0.25);
    canvas.translate(-ax, -ay);
    final shoe = Path()
      ..moveTo(ax - 2.5, ay)
      ..quadraticBezierTo(ax + fLen * 0.35, ay - 1.5, ax + fLen, ay + 1.0)
      ..lineTo(ax + fLen, ay + 4.0) ..lineTo(ax - 2.5, ay + 4.0) ..close();
    canvas.drawPath(shoe, fill);
    ink ..color = _ink.withValues(alpha: isFront ? inkAlpha * 0.82 : inkAlpha * 0.48) ..strokeWidth = 1.1;
    canvas.drawPath(shoe, ink);
    canvas.restore();
    ink ..color = _ink.withValues(alpha: inkAlpha) ..strokeWidth = 1.85;
  }

  void _drawArm(Canvas canvas, double cx, double shoulderY, double tW,
      double angle, double elbowBend, double uLen, double lLen,
      {required bool isFront, required Paint ink, required Paint fill, required double inkAlpha}) {
    final sx = cx + (isFront ? tW * 0.40 : -tW * 0.40);
    final sy = shoulderY + 3.5;
    final ex = sx + math.sin(angle) * uLen;
    final ey = sy + math.cos(angle) * uLen;
    final wa = angle + elbowBend;
    final wx = ex + math.sin(wa) * lLen;
    final wy = ey + math.cos(wa) * lLen;
    final a  = isFront ? 1.0 : 0.60;
    fill.color = _shirt.withValues(alpha: a * 0.9);
    canvas.drawPath(Path()
      ..moveTo(sx - 3.2, sy) ..lineTo(ex - 2.6, ey)
      ..lineTo(ex + 2.6, ey) ..lineTo(sx + 3.2, sy) ..close(), fill);
    fill.color = _skin.withValues(alpha: a * 0.88);
    canvas.drawPath(Path()
      ..moveTo(ex - 2.6, ey) ..lineTo(wx - 2.0, wy)
      ..lineTo(wx + 2.0, wy) ..lineTo(ex + 2.6, ey) ..close(), fill);
    ink ..color = _ink.withValues(alpha: isFront ? inkAlpha : inkAlpha * 0.55)
        ..strokeWidth = isFront ? 1.85 : 1.40;
    canvas.drawLine(Offset(sx, sy), Offset(ex, ey), ink);
    canvas.drawLine(Offset(ex, ey), Offset(wx, wy), ink);
    fill.color = _skin.withValues(alpha: a);
    canvas.drawCircle(Offset(wx, wy), 3.0, fill);
    ink ..color = _ink.withValues(alpha: inkAlpha * 0.80) ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(wx, wy), 3.0, ink);
    ink ..color = _ink.withValues(alpha: inkAlpha) ..strokeWidth = 1.85;
  }

  void _drawBackpack(Canvas canvas, double cx, double shoulderY,
      double tH, double sway, Paint ink, Paint fill, double inkAlpha) {
    final bx = cx - 9.5 + sway * 0.28;
    final by = shoulderY + 3.5;
    const bw = 10.5;
    final bh = tH * 0.68;
    final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx - bw, by, bw, bh), const Radius.circular(4));
    fill.color = _bag;
    canvas.drawRRect(rr, fill);
    ink ..color = _ink.withValues(alpha: inkAlpha * 0.75) ..strokeWidth = 1.4;
    canvas.drawRRect(rr, ink);
    ink ..strokeWidth = 0.85 ..color = _ink.withValues(alpha: inkAlpha * 0.50);
    canvas.drawLine(Offset(bx - bw + 2, by + bh * 0.36),
        Offset(bx - 2, by + bh * 0.36), ink);
    ink ..color = _ink.withValues(alpha: inkAlpha) ..strokeWidth = 1.85;
  }

  void _drawTorso(Canvas canvas, double cx, double shoulderY, double hipY,
      double tW, double tH, Paint ink, Paint fill, double inkAlpha) {
    final hw = tW / 2;
    final path = Path()
      ..moveTo(cx - hw * 1.15, shoulderY) ..lineTo(cx + hw * 1.15, shoulderY)
      ..lineTo(cx + hw * 0.80, hipY) ..lineTo(cx - hw * 0.80, hipY) ..close();
    fill.color = _shirt;
    canvas.drawPath(path, fill);
    ink ..color = _ink.withValues(alpha: inkAlpha * 0.90) ..strokeWidth = 1.7;
    canvas.drawPath(path, ink);
    ink ..strokeWidth = 0.85 ..color = _ink.withValues(alpha: inkAlpha * 0.55);
    canvas.drawLine(Offset(cx - 2.8, shoulderY + 1.0), Offset(cx, shoulderY + 5.5), ink);
    canvas.drawLine(Offset(cx + 2.8, shoulderY + 1.0), Offset(cx, shoulderY + 5.5), ink);
    ink ..color = _ink.withValues(alpha: inkAlpha) ..strokeWidth = 1.85;
  }

  void _drawHead(Canvas canvas, double cx, double headCY, double hr,
      double bob, double hairLag, Paint ink, Paint fill, double inkAlpha) {
    final hcy = headCY + bob;
    fill.color = _skin;
    canvas.drawRect(Rect.fromLTWH(cx - 3.5, hcy + hr, 7.0, 5.5), fill);
    canvas.drawCircle(Offset(cx, hcy), hr, fill);
    ink ..color = _ink.withValues(alpha: inkAlpha * 0.92) ..strokeWidth = 1.85;
    canvas.drawCircle(Offset(cx, hcy), hr, ink);
    _drawHair(canvas, cx, hcy, hr, hairLag, ink, fill, inkAlpha);
    _drawFace(canvas, cx, hcy, hr, ink, fill, inkAlpha);
  }

  void _drawHair(Canvas canvas, double cx, double hcy, double hr,
      double lag, Paint ink, Paint fill, double inkAlpha) {
    final hx = cx + lag * 0.35;
    fill.color = _hair;
    final cap = Path()
      ..moveTo(hx - hr * 0.72, hcy - hr * 0.28)
      ..quadraticBezierTo(hx - hr * 0.48, hcy - hr * 1.32, hx, hcy - hr * 1.38)
      ..quadraticBezierTo(hx + hr * 0.52, hcy - hr * 1.32, hx + hr * 0.78, hcy - hr * 0.28)
      ..close();
    canvas.drawPath(cap, fill);
    ink ..color = _ink.withValues(alpha: inkAlpha * 0.78) ..strokeWidth = 1.3;
    canvas.drawPath(cap, ink);
    final strand = Path()
      ..moveTo(hx + hr * 0.72, hcy - hr * 0.18)
      ..quadraticBezierTo(
        hx + hr * 0.92 + lag * 0.55, hcy + hr * 0.32,
        hx + hr * 0.88 + lag * 0.80, hcy + hr * 0.62);
    ink ..color = _hair.withValues(alpha: inkAlpha * 0.82) ..strokeWidth = 1.5;
    canvas.drawPath(strand, ink);
    ink ..color = _ink.withValues(alpha: inkAlpha) ..strokeWidth = 1.85;
  }

  void _drawFace(Canvas canvas, double cx, double hcy, double hr,
      Paint ink, Paint fill, double inkAlpha) {
    final ex = cx + hr * 0.20;
    final ey = hcy - hr * 0.10;
    canvas.drawCircle(Offset(ex, ey), 2.3,
        Paint()..color = _ink.withValues(alpha: inkAlpha));
    canvas.drawCircle(Offset(ex + 0.8, ey - 0.8), 0.72,
        Paint()..color = Colors.white);
    final brow = Path()
      ..moveTo(ex - 3.0, ey - 4.5)
      ..quadraticBezierTo(ex, ey - 5.8, ex + 3.0, ey - 4.5);
    ink ..color = _hair.withValues(alpha: inkAlpha * 0.80) ..strokeWidth = 1.1;
    canvas.drawPath(brow, ink);
    final smile = Path()
      ..moveTo(ex - 3.8, hcy + hr * 0.26)
      ..quadraticBezierTo(ex, hcy + hr * 0.44, ex + 3.8, hcy + hr * 0.26);
    ink ..color = _ink.withValues(alpha: inkAlpha * 0.72) ..strokeWidth = 1.3;
    canvas.drawPath(smile, ink);
    canvas.drawCircle(Offset(ex + 5.5, hcy + hr * 0.05), 3.8,
        Paint()..color = const Color(0xFFFFB5BA).withValues(alpha: 0.52));
    ink ..color = _ink.withValues(alpha: inkAlpha) ..strokeWidth = 1.85;
  }

  // ── Refresh crowd ─────────────────────────────────────────────────────────

  static const _crowdShirts = [
    Color(0xFFA78BFA), Color(0xFF60A5FA), Color(0xFF34D399),
    Color(0xFFF472B6), Color(0xFFFBBF24),
  ];
  static const _crowdX = [0.10, 0.26, 0.50, 0.72, 0.88];

  void _paintRefreshCrowd(Canvas canvas, Size size) {
    final groundY = size.height * _horizonFrac;
    final ink = _theme.inkAlpha;
    for (var i = 0; i < 5; i++) {
      final cx = _crowdX[i] * size.width;
      final jumpT = (walkPhase * 2.5 + i / 5.0) * math.pi;
      final air   = math.sin(jumpT).abs();
      final atGround = 1.0 - air;
      final scX = 1.0 + 0.20 * atGround * atGround;
      final scY = 1.0 - 0.12 * atGround * atGround;
      final jumpH   = 13.0 * air;
      final feetY   = groundY - jumpH;
      final shadowS = (1.0 - air * 0.75).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, groundY + 2.5),
            width: 18 * shadowS * scX, height: 4 * shadowS),
        Paint()..color = _ink.withValues(alpha: 0.14 * shadowS),
      );
      _drawMiniJumper(canvas, cx, feetY, scX, scY, air, _crowdShirts[i], ink);
    }
  }

  void _drawMiniJumper(Canvas canvas, double cx, double feetY,
      double scX, double scY, double air, Color shirtColor, double inkAlpha) {
    const headR  = 5.0;
    const neckH  = 2.5;
    const bodyH  = 9.0;
    const bodyW  = 7.0;
    const armL   = 7.5;
    const legL   = 8.5;
    const shoeW  = 5.5;
    const shoeH  = 3.0;
    final hipY      = feetY   - legL  * scY;
    final shoulderY = hipY    - bodyH * scY;
    final headCY    = shoulderY - neckH - headR * scX;
    final strokeInk = Paint()
      ..color = _ink.withValues(alpha: inkAlpha * 0.72)
      ..strokeWidth = 0.85
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final legXOff = 2.0 + air * 3.0;
    final legPaint = Paint()
      ..color = _pants.withValues(alpha: 0.9)
      ..strokeWidth = 2.1 * scX
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 1.2, hipY), Offset(cx - legXOff, feetY), legPaint);
    canvas.drawLine(Offset(cx + 1.2, hipY), Offset(cx + legXOff, feetY), legPaint);
    final shoeFill = Paint()..color = _shoe;
    for (final side in [-1.0, 1.0]) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + side * legXOff, feetY + shoeH / 2 - 0.5),
            width: shoeW * scX, height: shoeH * scY),
        const Radius.circular(2)), shoeFill);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, (shoulderY + hipY) / 2),
          width: bodyW * scX, height: bodyH * scY),
      const Radius.circular(3.5)), Paint()..color = shirtColor);
    final armDeg = 30.0 + air * 110.0;
    final armRad = armDeg * math.pi / 180;
    final armDx  = armL * math.sin(armRad);
    final armDy  = armL * math.cos(armRad);
    final armPaint = Paint()
      ..color = shirtColor ..strokeWidth = 2.2 ..strokeCap = StrokeCap.round;
    final sxL = cx - bodyW * scX * 0.44;
    final sxR = cx + bodyW * scX * 0.44;
    canvas.drawLine(Offset(sxL, shoulderY + 1),
        Offset(sxL - armDx, shoulderY + 1 + armDy), armPaint);
    canvas.drawLine(Offset(sxR, shoulderY + 1),
        Offset(sxR + armDx, shoulderY + 1 + armDy), armPaint);
    final hr = headR * scX;
    canvas.drawCircle(Offset(cx, headCY), hr, Paint()..color = _skin);
    canvas.drawCircle(Offset(cx, headCY), hr, strokeInk);
    for (final side in [-1.0, 1.0]) {
      canvas.drawCircle(Offset(cx + side * hr * 0.55, headCY + hr * 0.10), hr * 0.38,
          Paint()..color = const Color(0xFFFFB5BA).withValues(alpha: 0.50));
    }
    final hairLag = air * hr * 0.35;
    final hairPath = Path()
      ..moveTo(cx - hr * 0.76, headCY - hr * 0.18)
      ..quadraticBezierTo(cx, headCY - hr * 1.30 - hairLag,
          cx + hr * 0.76, headCY - hr * 0.18);
    canvas.drawPath(hairPath, Paint()
      ..color = _hair ..strokeWidth = 1.6 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
    final eyeY = headCY - hr * 0.08;
    canvas.drawCircle(Offset(cx - hr * 0.33, eyeY), 0.95,
        Paint()..color = _ink.withValues(alpha: inkAlpha));
    canvas.drawCircle(Offset(cx + hr * 0.33, eyeY), 0.95,
        Paint()..color = _ink.withValues(alpha: inkAlpha));
    if (air > 0.45) {
      canvas.drawCircle(Offset(cx, headCY + hr * 0.38), 1.4,
          Paint()..color = _ink.withValues(alpha: inkAlpha * 0.68));
      for (final side in [-1.0, 1.0]) {
        canvas.drawLine(
          Offset(cx + side * hr * 0.50, eyeY - hr * 0.55),
          Offset(cx + side * hr * 0.18, eyeY - hr * 0.72),
          strokeInk..strokeWidth = 0.9);
      }
    } else {
      final smile = Path()
        ..moveTo(cx - hr * 0.42, headCY + hr * 0.26)
        ..quadraticBezierTo(cx, headCY + hr * 0.48, cx + hr * 0.42, headCY + hr * 0.26);
      canvas.drawPath(smile, Paint()
        ..color = _ink.withValues(alpha: inkAlpha * 0.68)
        ..strokeWidth = 1.0 ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(WalkingStudentPainter old) =>
      old.walkPhase   != walkPhase   ||
      old.scrollPhase != scrollPhase ||
      old.isRefreshing != isRefreshing ||
      old.hour        != hour;
}
