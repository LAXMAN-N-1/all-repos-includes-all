import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../models/station_state.dart';
import 'swap_port_modals.dart';

// ══════════════════════════════════════════════════════════
// SWAP PORT GRID — Visually spectacular port visualization
// ══════════════════════════════════════════════════════════

class SwapPortGrid extends StatelessWidget {
  final StationSwapDataDto data;
  final bool isCompact;
  final int stationId;
  final Function(int stationId, int portNumber)? onMarkFixed;
  final Function(int stationId, int portNumber)? onMarkOffline;
  final Function(int stationId, int portNumber, String minutes)? onReserve;

  const SwapPortGrid({
    super.key,
    required this.data,
    required this.stationId,
    this.isCompact = false,
    this.onMarkFixed,
    this.onMarkOffline,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final portSize = isCompact ? 80.0 : 105.0;
    final chargingCount = data.ports.where((p) => p.state == 'charging').length;
    final faultCount = data.ports.where((p) => p.state == 'fault').length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Station header
      Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.primary.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.radio, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.stationName, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          )),
          Text('${data.totalPorts} ports', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ])),
        // Status chips
        _chip('${data.activeSwaps}', 'Active', AppColors.amber),
        const SizedBox(width: 6),
        _chip('${data.availablePorts}', 'Ready', AppColors.primary),
        const SizedBox(width: 6),
        _chip('$chargingCount', 'Charging', AppColors.cyan),
        if (faultCount > 0) ...[
          const SizedBox(width: 6),
          _chip('$faultCount', 'Fault', AppColors.red),
        ],
      ]),
      const SizedBox(height: 18),

      // Port grid
      Wrap(
        spacing: isCompact ? 8 : 10,
        runSpacing: isCompact ? 8 : 10,
        children: data.ports.map((p) => _PortCard(
          port: p,
          size: portSize,
          isCompact: isCompact,
          stationId: stationId,
          stationName: data.stationName,
          onMarkFixed: onMarkFixed,
          onMarkOffline: onMarkOffline,
          onReserve: onReserve,
        )).toList(),
      ),

      const SizedBox(height: 16),

      // Summary strip
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.pageBg.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _summaryItem('Total', '${data.totalPorts}', AppColors.textSecondary),
          _summaryItem('Active', '${data.activeSwaps}', AppColors.amber),
          _summaryItem('Charging', '$chargingCount', AppColors.cyan),
          _summaryItem('Ready', '${data.availablePorts}', AppColors.primary),
          _summaryItem('Faults', '$faultCount', AppColors.red),
        ]),
      ),
    ]);
  }

  Widget _chip(String count, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.8))),
    ]),
  );

  Widget _summaryItem(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
  ]);
}


// ══════════════════════════════════════════════════════════
// PORT CARD — Individual port with 6 visual states
// ══════════════════════════════════════════════════════════

class _PortCard extends StatefulWidget {
  final SwapPortDto port;
  final double size;
  final bool isCompact;
  final int stationId;
  final String stationName;
  final Function(int, int)? onMarkFixed;
  final Function(int, int)? onMarkOffline;
  final Function(int, int, String)? onReserve;

  const _PortCard({
    required this.port,
    required this.size,
    required this.isCompact,
    required this.stationId,
    required this.stationName,
    this.onMarkFixed,
    this.onMarkOffline,
    this.onReserve,
  });

  @override
  State<_PortCard> createState() => _PortCardState();
}

class _PortCardState extends State<_PortCard> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _spinCtrl;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    final pulseDuration = switch (widget.port.state) {
      'active' => 1200,
      'ready' => 2500,
      'fault' => 1800,
      _ => 2000,
    };
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: pulseDuration),
    );
    final shouldPulse = ['ready', 'active', 'fault'].contains(widget.port.state);
    if (shouldPulse) _pulseCtrl.repeat(reverse: true);

    // Spin for active swap
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.port.state == 'active') _spinCtrl.repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  Color get _baseColor => switch (widget.port.state) {
    'ready' => AppColors.primary,
    'active' => AppColors.amber,
    'charging' => AppColors.cyan,
    'fault' => AppColors.red,
    'offline' => AppColors.textMuted,
    'reserved' => AppColors.purple,
    _ => AppColors.border,
  };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseCtrl, _spinCtrl]),
          builder: (_, __) => _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final pulse = _pulseCtrl.value;
    final color = _baseColor;
    final isInert = widget.port.state == 'offline';

    // Dynamic glow
    final bgOpacity = isInert ? 0.05 : (0.08 + pulse * (widget.port.state == 'active' ? 0.1 : 0.06));
    final borderOpacity = isInert ? 0.15 : (0.25 + pulse * 0.15);
    final glowRadius = isInert ? 0.0 : (8 + pulse * 8);

    return AnimatedScale(
      scale: _isHovered ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: bgOpacity),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: borderOpacity),
            width: widget.port.state == 'fault' ? 2 : 1.5,
          ),
          boxShadow: !isInert ? [BoxShadow(
            color: color.withValues(alpha: 0.12 + pulse * 0.08),
            blurRadius: glowRadius,
            spreadRadius: widget.port.state == 'active' ? 2 : 0,
          )] : [],
        ),
        child: Stack(children: [
          // Charge arc for CHARGING state
          if (widget.port.state == 'charging')
            Positioned.fill(child: CustomPaint(
              painter: _ChargeArcPainter(
                progress: widget.port.chargePercent / 100,
                color: AppColors.cyan,
              ),
            )),

          // Alert badge for FAULT state
          if (widget.port.state == 'fault')
            Positioned(top: 4, right: 4, child: Icon(
              LucideIcons.bellRing, size: 10,
              color: AppColors.red.withValues(alpha: 0.6 + pulse * 0.4),
            )),

          // Port number
          Positioned(top: 5, left: 7, child: Text(
            '${widget.port.portNumber}',
            style: TextStyle(
              fontSize: 8, fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.5),
            ),
          )),

          // Main content
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _buildIcon(color),
              const SizedBox(height: 4),
              _buildPrimaryLabel(color),
              if (!widget.isCompact) ...[
                const SizedBox(height: 2),
                _buildSecondaryLabel(color),
              ],
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    final iconSize = widget.isCompact ? 18.0 : 22.0;

    return switch (widget.port.state) {
      'ready' => Icon(LucideIcons.batteryFull, size: iconSize, color: color),
      'active' => RotationTransition(
        turns: _spinCtrl,
        child: Icon(LucideIcons.refreshCw, size: iconSize, color: color),
      ),
      'charging' => Stack(alignment: Alignment.center, children: [
        Icon(LucideIcons.battery, size: iconSize, color: color),
        Icon(LucideIcons.zap, size: iconSize * 0.5, color: color),
      ]),
      'fault' => Icon(LucideIcons.xCircle, size: iconSize, color: color),
      'offline' => Icon(LucideIcons.minus, size: iconSize, color: color),
      'reserved' => Icon(LucideIcons.lock, size: iconSize, color: color),
      _ => Icon(LucideIcons.circle, size: iconSize, color: color),
    };
  }

  Widget _buildPrimaryLabel(Color color) {
    final fontSize = widget.isCompact ? 9.0 : 10.0;

    return switch (widget.port.state) {
      'ready' => Text('READY', style: TextStyle(
        fontSize: fontSize, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5,
      )),
      'active' => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.port.customerName ?? 'SWAP', style: TextStyle(
          fontSize: fontSize, fontWeight: FontWeight.w600, color: Colors.white,
        ), overflow: TextOverflow.ellipsis, maxLines: 1),
        if (widget.port.swapStartedAt != null) _liveTimer(),
      ]),
      'charging' => Text('${widget.port.chargePercent.toStringAsFixed(0)}%', style: TextStyle(
        fontSize: widget.isCompact ? 11 : 14, fontWeight: FontWeight.w800, color: color,
      )),
      'fault' => Text('FAULT', style: TextStyle(
        fontSize: fontSize, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5,
      )),
      'offline' => Text('OFF', style: TextStyle(
        fontSize: fontSize, fontWeight: FontWeight.w600, color: color,
      )),
      'reserved' => Text('RESERVED', style: TextStyle(
        fontSize: fontSize - 1, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.3,
      )),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSecondaryLabel(Color color) {
    final state = widget.port.state;
    final code = widget.port.batteryCode;

    if ((state == 'active' || state == 'charging') && code != null) {
      return Text(
        code,
        style: TextStyle(fontSize: 8, color: color.withValues(alpha: 0.7), fontFamily: 'monospace'),
        overflow: TextOverflow.ellipsis,
      );
    }
    if (state == 'fault') {
      return Text(
        widget.port.faultCode ?? 'ERROR',
        style: TextStyle(fontSize: 7, color: color.withValues(alpha: 0.6)),
        overflow: TextOverflow.ellipsis,
      );
    }
    if (state == 'reserved' && widget.port.reservationExpiry != null) {
      return _reservationTimer();
    }
    return const SizedBox.shrink();
  }

  Widget _liveTimer() {
    try {
      final started = DateTime.parse(widget.port.swapStartedAt!).toLocal();
      final elapsed = DateTime.now().difference(started);
      final mins = elapsed.inMinutes;
      final secs = elapsed.inSeconds % 60;
      return Text('${mins}m ${secs}s', style: TextStyle(
        fontSize: widget.isCompact ? 9 : 11, fontWeight: FontWeight.w800,
        color: AppColors.amber,
      ));
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _reservationTimer() {
    try {
      final expiry = DateTime.parse(widget.port.reservationExpiry!).toLocal();
      final remaining = expiry.difference(DateTime.now());
      if (remaining.isNegative) return const Text('Expired', style: TextStyle(fontSize: 8, color: AppColors.red));
      return Text('${remaining.inMinutes}m left', style: TextStyle(
        fontSize: 8, color: AppColors.purple.withValues(alpha: 0.8),
      ));
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  void _handleTap(BuildContext context) {
    switch (widget.port.state) {
      case 'active':
        SwapPortModals.showActiveSwapModal(context, widget.port, widget.stationName);
        break;
      case 'fault':
        SwapPortModals.showFaultModal(
          context, widget.port, widget.stationName,
          onMarkFixed: () => widget.onMarkFixed?.call(widget.stationId, widget.port.portNumber),
          onScheduleMaintenance: () {},
        );
        break;
      case 'ready':
        SwapPortModals.showReadyPortModal(
          context, widget.port, widget.stationName,
          onMarkOffline: () => widget.onMarkOffline?.call(widget.stationId, widget.port.portNumber),
          onReserve: (mins) => widget.onReserve?.call(widget.stationId, widget.port.portNumber, mins),
        );
        break;
    }
  }
}


// ── Charge Arc Painter ──────────────────────────────────
class _ChargeArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ChargeArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final fgPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress * 2 * pi,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChargeArcPainter old) => old.progress != progress;
}
