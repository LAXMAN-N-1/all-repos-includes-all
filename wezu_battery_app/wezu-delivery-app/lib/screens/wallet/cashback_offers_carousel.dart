import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cashback_offer.dart';

/// Horizontal scrolling carousel of cashback offer cards + scratch-card section.
/// Hidden entirely (returns [SizedBox.shrink]) when [offers] is empty.
class CashbackOffersCarousel extends StatelessWidget {
  const CashbackOffersCarousel({
    super.key,
    required this.offers,
    required this.isLoading,
  });

  final List<CashbackOffer> offers;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 130,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFD802E)),
        ),
      );
    }
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Special Offers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // ── Regular offer cards ─────────────────────────────────────────────
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _OfferCard(offer: offers[i]),
          ),
        ),

        const SizedBox(height: 20),

        // ── Scratch card section ────────────────────────────────────────────
        const _ScratchCardSection(),
      ],
    );
  }
}

// ─── Offer Card ───────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});
  final CashbackOffer offer;

  @override
  Widget build(BuildContext context) {
    final cat = offer.category;
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cat.cardColor, cat.cardColor.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cat.accentColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                cat.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: cat.accentColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Until ${DateFormat('MMM d, y').format(offer.expiryDate)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                TextButton(
                  onPressed: () => _showDetails(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OfferDetailsSheet(offer: offer),
    );
  }
}

// ─── Offer Details Sheet ──────────────────────────────────────────────────────

class _OfferDetailsSheet extends StatelessWidget {
  const _OfferDetailsSheet({required this.offer});
  final CashbackOffer offer;

  @override
  Widget build(BuildContext context) {
    final cat = offer.category;
    return Container(
      margin: const EdgeInsets.only(top: 64),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cat.cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cat.accentColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cat.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: cat.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valid until ${DateFormat('MMMM d, y').format(offer.expiryDate)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF233D4C),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.terms,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scratch Card Section ─────────────────────────────────────────────────────

class _ScratchCardSection extends StatelessWidget {
  const _ScratchCardSection();

  static const _prizes = [
    _Prize('₹25 Cashback', '🎉', Color(0xFF2E7D32)),
    _Prize('₹50 Bonus', '🏆', Color(0xFF1565C0)),
    _Prize('₹10 Reward', '✨', Color(0xFFFFA726)),
    _Prize('Better luck\nnext time', '🍀', Color(0xFF757575)),
    _Prize('₹100 Cashback', '🎊', Color(0xFFC62828)),
    _Prize('₹15 Cashback', '⭐', Color(0xFF6A1B9A)),
  ];

  @override
  Widget build(BuildContext context) {
    // Pick a pseudo-random prize seeded by the current day so it feels fresh
    final prize = _prizes[DateTime.now().day % _prizes.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Scratch Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233D4C),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFD802E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '1 remaining today',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFD802E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Scratch to reveal your reward!',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 12),
        _ScratchCard(prize: prize),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'New card available tomorrow',
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }
}

class _Prize {
  const _Prize(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;
}

// ─── Interactive Scratch Card ─────────────────────────────────────────────────

class _ScratchCard extends StatefulWidget {
  const _ScratchCard({required this.prize});
  final _Prize prize;

  @override
  State<_ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<_ScratchCard>
    with SingleTickerProviderStateMixin {
  final List<Offset> _scratchedPoints = [];
  bool _revealed = false;
  bool _rewardClaimed = false;
  late AnimationController _glowController;

  // ~35% coverage triggers full reveal
  static const _revealThreshold = 20;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (_revealed) return;
    setState(() {
      _scratchedPoints.add(d.localPosition);
      if (_scratchedPoints.length > _revealThreshold && !_revealed) {
        _revealed = true;
        _onRevealed();
      }
    });
  }

  void _onRevealed() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final isWin = !widget.prize.label.contains('luck');
      if (isWin && !_rewardClaimed) {
        _rewardClaimed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text('🎉 ${widget.prize.label} applied to your wallet!'),
              ],
            ),
            backgroundColor: widget.prize.color,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        const cardHeight = 160.0;

        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: GestureDetector(
            onPanUpdate: (d) => _onPanUpdate(d, Size(cardWidth, cardHeight)),
            child: Stack(
              children: [
                // ── Prize layer (underneath) ──────────────────────────────
                _buildPrizeLayer(cardWidth, cardHeight),

                // ── Scratch overlay (on top) ──────────────────────────────
                if (!_revealed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      size: Size(cardWidth, cardHeight),
                      painter: _ScratchPainter(
                        scratchedPoints: _scratchedPoints,
                      ),
                    ),
                  ),

                // ── Hint text (before any scratching) ────────────────────
                if (_scratchedPoints.isEmpty && !_revealed)
                  Positioned.fill(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (_, child) => Opacity(
                          opacity: 0.6 + _glowController.value * 0.4,
                          child: child,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Scratch here!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrizeLayer(double w, double h) {
    final prize = widget.prize;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [prize.color.withValues(alpha: 0.9), prize.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prize.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(
            prize.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          if (_revealed && !prize.label.contains('luck')) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Reward Applied ✓',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Scratch Painter ──────────────────────────────────────────────────────────

class _ScratchPainter extends CustomPainter {
  const _ScratchPainter({required this.scratchedPoints});

  final List<Offset> scratchedPoints;

  @override
  void paint(Canvas canvas, Size size) {
    // Silver foil background
    final foilGrad = LinearGradient(
      colors: [
        const Color(0xFFB8C0CC),
        const Color(0xFFD4DCE8),
        const Color(0xFFACADB0),
        const Color(0xFFD0D3D8),
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final foilPaint = Paint()..shader = foilGrad.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      foilPaint,
    );

    // Subtle sparkle dots
    final r = Random(42);
    final sparkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 60; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), r.nextDouble() * 2.5, sparkPaint);
    }

    // Erase scratched areas
    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    for (final point in scratchedPoints) {
      canvas.drawCircle(point, 28, erasePaint);
    }
  }

  @override
  bool shouldRepaint(_ScratchPainter old) =>
      old.scratchedPoints.length != scratchedPoints.length;
}
