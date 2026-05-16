import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../dashboard/dashboard_view_model.dart';
import '../delivery/active_delivery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _defaultCamera = CameraPosition(
    target: LatLng(16.9891, 82.2475),
    zoom: 11.4,
  );

  GoogleMapController? _mapController;
  OrderRepository? _orderRepository;
  Timer? _refreshTimer;

  late final AnimationController _entryController;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _mapScale;

  Order? _incomingOrder;
  Order? _activeOrder;
  bool _isRequestSheetOpen = false;
  bool _showPromo = true;
  String? _lastHandledRequestId;

  bool _autoOpenRequests = true;
  bool _nearbyOnly = false;
  double _maxDistanceKm = 18;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );
    _mapScale = Tween<double>(begin: 0.965, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutBack),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _orderRepository = context.read<OrderRepository>();
      _orderRepository!.addListener(_syncOrders);
      _orderRepository!.fetchAssignments();

      _refreshTimer = Timer.periodic(const Duration(seconds: 18), (_) {
        if (!mounted) return;
        _orderRepository?.fetchAssignments();
      });

      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _orderRepository?.removeListener(_syncOrders);
    _mapController?.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _syncOrders() {
    if (!mounted || _orderRepository == null) return;

    final orders = _orderRepository!.orders;
    final pending = orders
        .where((o) => o.status == OrderStatus.pending)
        .where(_passesFilter)
        .toList();

    final active = orders
        .where(
          (o) =>
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.pickingUp ||
              o.status == OrderStatus.delivering,
        )
        .toList();

    setState(() {
      _incomingOrder = pending.isEmpty ? null : pending.first;
      _activeOrder = active.isEmpty ? null : active.first;
    });

    final shouldPrompt =
        _autoOpenRequests &&
        _incomingOrder != null &&
        !_isRequestSheetOpen &&
        _incomingOrder!.id != _lastHandledRequestId &&
        context.read<DashboardViewModel>().isOnline;

    if (shouldPrompt) {
      _showOrderRequestSheet(_incomingOrder!);
    }
  }

  bool _passesFilter(Order order) {
    if (!_nearbyOnly) return true;
    final distance = order.distance;
    if (distance <= 0) return true;
    return distance <= _maxDistanceKm;
  }

  Future<void> _showOrderRequestSheet(Order order) async {
    _isRequestSheetOpen = true;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E1E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'New delivery request',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Order #${order.id}',
                style: const TextStyle(color: Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              _locationRow(Icons.store_outlined, 'Pickup', order.pickupAddress),
              const SizedBox(height: 8),
              _locationRow(
                Icons.location_on_outlined,
                'Drop',
                order.dropoffAddress,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated payout',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                    Text(
                      '₹${order.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await context.read<OrderRepository>().updateOrderStatus(
                          order.id,
                          OrderStatus.cancelled,
                        );
                        _lastHandledRequestId = order.id;
                        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      },
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        await context.read<OrderRepository>().updateOrderStatus(
                          order.id,
                          OrderStatus.accepted,
                        );
                        _lastHandledRequestId = order.id;
                        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      },
                      child: const Text('Accept request'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    _isRequestSheetOpen = false;
  }

  Future<void> _handleOnlineToggle(DashboardViewModel dashboard) async {
    final next = !dashboard.isOnline;
    final success = await dashboard.toggleOnlineStatus(next);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (next ? 'You are online now.' : 'You are offline now.')
              : (dashboard.lastStatusError ??
                    'Unable to update online status. Please retry.'),
        ),
      ),
    );
  }

  Future<void> _showSafetySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety tools',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.call, color: Colors.black),
                  title: const Text('Emergency support'),
                  subtitle: const Text('Call partner support hotline'),
                  onTap: () async {
                    final uri = Uri.parse('tel:+18001234567');
                    final launched = await launchUrl(uri);
                    if (!launched && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Calling is unavailable on this device.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.help_outline, color: Colors.black),
                  title: const Text('Safety help center'),
                  subtitle: const Text('Open support and safety guidelines'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/help-support');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.share_location,
                    color: Colors.black,
                  ),
                  title: const Text('Share live status'),
                  subtitle: const Text('Let support know your current route'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Live status shared with support.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilterSheet() async {
    bool localNearbyOnly = _nearbyOnly;
    bool localAutoOpen = _autoOpenRequests;
    double localMaxDistance = _maxDistanceKm;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Delivery filters',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setLocalState(() {
                              localNearbyOnly = false;
                              localAutoOpen = true;
                              localMaxDistance = 18;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: localNearbyOnly,
                      onChanged: (value) {
                        setLocalState(() => localNearbyOnly = value);
                      },
                      title: const Text('Nearby requests only'),
                      subtitle: const Text('Hide long-distance requests'),
                      activeTrackColor: Colors.black,
                    ),
                    if (localNearbyOnly)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Max distance: ${localMaxDistance.toStringAsFixed(0)} km',
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Slider(
                            value: localMaxDistance,
                            min: 2,
                            max: 40,
                            divisions: 19,
                            label: '${localMaxDistance.toStringAsFixed(0)} km',
                            onChanged: (value) {
                              setLocalState(() => localMaxDistance = value);
                            },
                          ),
                        ],
                      ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: localAutoOpen,
                      onChanged: (value) {
                        setLocalState(() => localAutoOpen = value);
                      },
                      title: const Text('Auto-open new request sheet'),
                      subtitle: const Text(
                        'Prompt immediately when requests arrive',
                      ),
                      activeTrackColor: Colors.black,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (applied != true || !mounted) return;

    setState(() {
      _nearbyOnly = localNearbyOnly;
      _autoOpenRequests = localAutoOpen;
      _maxDistanceKm = localMaxDistance;
    });

    _syncOrders();
  }

  Future<void> _openMapSearch({String? query}) async {
    final q = query?.trim().isNotEmpty == true
        ? query!.trim()
        : 'EV battery delivery near me';

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
    );

    final launched = await launchUrl(url, mode: LaunchMode.platformDefault);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open map search right now.')),
      );
    }
  }

  Future<void> _expandMap() async {
    if (!kIsWeb && _mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
      return;
    }

    await _openMapSearch(
      query: _activeOrder?.dropoffAddress ?? 'battery delivery zone near me',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboard, _) {
        final isOnline = dashboard.isOnline;
        final isToggling = dashboard.isTogglingStatus;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _RoundIconButton(
                        icon: Icons.shield_outlined,
                        onTap: _showSafetySheet,
                      ),
                      const SizedBox(width: 8),
                      _RoundIconButton(
                        icon: Icons.tune,
                        onTap: _showFilterSheet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SlideTransition(
                    position: _headlineSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: Text(
                            isOnline ? "You're online" : "You're offline",
                            key: ValueKey<bool>(isOnline),
                            style: const TextStyle(
                              fontSize: 54,
                              height: 0.98,
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isOnline
                              ? (_activeOrder == null
                                    ? 'Waiting for delivery requests'
                                    : 'Delivery in progress')
                              : 'Ready to go?',
                          style: const TextStyle(
                            color: Color(0xFF4D4D4D),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScaleTransition(
                    scale: _mapScale,
                    child: _MapCard(
                      onCreated: (controller) => _mapController = controller,
                      onExpandTap: _expandMap,
                      onSearchTap: () =>
                          _openMapSearch(query: _activeOrder?.dropoffAddress),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: _activeOrder == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ActiveOrderPanel(
                              key: ValueKey<String>(_activeOrder!.id),
                              order: _activeOrder!,
                              onOpen: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ActiveDeliveryScreen(
                                      order: _activeOrder!,
                                    ),
                                  ),
                                );
                              },
                              onNavigate: () => _openMapSearch(
                                query: _activeOrder!.dropoffAddress,
                              ),
                            ),
                          ),
                  ),
                  if (_showPromo) ...[
                    const SizedBox(height: 14),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Get 0% commission today',
                                  style: TextStyle(
                                    fontSize: 34,
                                    height: 1.0,
                                    letterSpacing: -0.9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _showPromo = false),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Complete one delivery to activate the daily pass offer.',
                            style: TextStyle(
                              color: Color(0xFF5D5D5D),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  AnimatedScale(
                    scale: isToggling ? 0.985 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: isToggling
                            ? null
                            : () => _handleOnlineToggle(dashboard),
                        icon: isToggling
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isOnline
                                    ? Icons.pause_circle_outline
                                    : Icons.radio_button_checked,
                                color: Colors.white,
                              ),
                        label: Text(
                          isOnline ? 'Go offline' : 'Go online',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _locationRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5E5E5E),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  final ValueChanged<GoogleMapController> onCreated;
  final VoidCallback onExpandTap;
  final VoidCallback onSearchTap;

  const _MapCard({
    required this.onCreated,
    required this.onExpandTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 360,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: kIsWeb
                  ? const _WebMapFallback()
                  : GoogleMap(
                      initialCameraPosition: _HomeScreenState._defaultCamera,
                      onMapCreated: onCreated,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _RoundIconButton(
                icon: Icons.open_in_full,
                onTap: onExpandTap,
                small: false,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _RoundIconButton(
                icon: Icons.search,
                onTap: onSearchTap,
                small: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebMapFallback extends StatelessWidget {
  const _WebMapFallback();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _MapPatternPainter())),
        Center(
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: const Icon(Icons.navigation, color: Colors.black, size: 34),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Map preview mode on web. Tap search for live navigation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8EBEF);
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = const Color(0xFFC7CFD8)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final minorRoad = Paint()
      ..color = const Color(0xFFD8DEE5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pathA = Path()
      ..moveTo(0, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.14,
        size.width * 0.58,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.4,
        size.width,
        size.height * 0.35,
      );
    canvas.drawPath(pathA, road);

    final pathB = Path()
      ..moveTo(size.width * 0.15, 0)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.35,
        size.width * 0.3,
        size.height,
      );
    canvas.drawPath(pathB, road);

    final pathC = Path()
      ..moveTo(size.width * 0.7, 0)
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.4,
        size.width * 0.78,
        size.height,
      );
    canvas.drawPath(pathC, minorRoad);

    final pathD = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.62,
        size.width * 0.46,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.67,
        size.height * 0.8,
        size.width,
        size.height * 0.7,
      );
    canvas.drawPath(pathD, minorRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool small;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.small = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 56.0 : 66.0;

    return Material(
      color: const Color(0xFFF2F2F2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.black, size: 30),
        ),
      ),
    );
  }
}

class _ActiveOrderPanel extends StatelessWidget {
  final Order order;
  final VoidCallback onOpen;
  final VoidCallback onNavigate;

  const _ActiveOrderPanel({
    super.key,
    required this.order,
    required this.onOpen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active delivery',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order #${order.id}',
            style: const TextStyle(color: Color(0xFFD5D5D5), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onNavigate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Navigate'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Open delivery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
