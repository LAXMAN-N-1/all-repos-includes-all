import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/campaign_provider.dart';

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});
  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12; final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(animation: _c, builder: (c, _) {
      final t = Curves.easeOut.transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignsProvider);
    final all = state.campaigns;

    // KPI
    final active = all.where((c) => c.status.toLowerCase() == 'active').length;
    final totalRedemptions = all.fold<int>(0, (sum, c) => sum + (int.tryParse(c.redemptions) ?? 0));

    // Filter
    final filtered = _filter == 'All' ? all : all.where((c) => c.status.toLowerCase() == _filter.toLowerCase()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPI Row
        _stagger(0, child: Row(children: [
          Expanded(child: _KpiCard(label: 'TOTAL CAMPAIGNS', value: '${all.length}', icon: LucideIcons.megaphone, accent: AppColors.purple)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(label: 'ACTIVE', value: '$active', icon: LucideIcons.zap, accent: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(label: 'TOTAL REDEMPTIONS', value: '$totalRedemptions', icon: LucideIcons.gift, accent: AppColors.cyan)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(label: 'INACTIVE', value: '${all.length - active}', icon: LucideIcons.pause, accent: AppColors.amber)),
        ])),
        const SizedBox(height: 20),

        // Filter tabs + New button
        _stagger(1, child: Row(children: [
          ...['All', 'Active', 'Inactive'].map((f) {
            final sel = _filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.purple.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? AppColors.purple.withValues(alpha: 0.3) : AppColors.border),
                  ),
                  child: Text(f, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppColors.purple : AppColors.textSecondary)),
                ),
              ),
            );
          }),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('New Campaign'),
            onPressed: () => _showCreateCampaign(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ])),
        const SizedBox(height: 16),

        // Campaign Cards Grid
        _stagger(2, child: state.isLoading
          ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          : state.error != null
            ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.red))))
            : filtered.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No campaigns found', style: TextStyle(color: AppColors.textSecondary))))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.6, crossAxisSpacing: 14, mainAxisSpacing: 14),
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _CampaignCard(c: filtered[i]),
                ),
        ),
      ]),
    );
  }

  void _showCreateCampaign(BuildContext context) {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    final codeC = TextEditingController();
    final valueC = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(LucideIcons.megaphone, color: AppColors.purple, size: 20),
          SizedBox(width: 10),
          Text('New Campaign', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        ]),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(nameC, 'Campaign Name', LucideIcons.tag),
            const SizedBox(height: 12),
            _field(descC, 'Description', LucideIcons.fileText),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field(codeC, 'Promo Code', LucideIcons.hash)),
              const SizedBox(width: 12),
              Expanded(child: _field(valueC, 'Discount %', LucideIcons.percent)),
            ]),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign created'), backgroundColor: AppColors.purple)); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
            child: const Text('Create Campaign'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) => TextField(
    controller: c, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
      prefixIcon: Icon(icon, size: 16, color: AppColors.textTertiary),
      filled: true, fillColor: AppColors.pageBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    ),
  );
}

class _CampaignCard extends StatefulWidget {
  final dynamic c;
  const _CampaignCard({required this.c});
  @override
  State<_CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<_CampaignCard> {
  bool _hovered = false;

  void _showCampaignDetails(BuildContext context) {
    final c = widget.c;
    final isActive = c.status.toLowerCase() == 'active';
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isActive ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4), border: Border.all(color: (isActive ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.3)),
                    ),
                    child: Text(c.status.toString().toUpperCase(), style: TextStyle(color: isActive ? AppColors.primary : AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  Text(c.title.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(c.desc.toString(), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ])),
                IconButton(icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textTertiary), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Navigator.pop(ctx)),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('METRICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _metricBox('Redemptions', '${c.redemptions}', LucideIcons.gift, AppColors.purple)),
                  const SizedBox(width: 12),
                  Expanded(child: _metricBox('Est. Value', currency.format(int.tryParse(c.redemptions) ?? 0 * 50), LucideIcons.trendingUp, AppColors.cyan)),
                ]),
                const SizedBox(height: 24),
                const Text('DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                _detailRow('Promo Code', c.title.toString().split(' ').first.toUpperCase()),
                const SizedBox(height: 10),
                _detailRow('Valid Dates', c.dates.toString()),
                const SizedBox(height: 10),
                _detailRow('Discount', '10% OFF'),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.edit, size: 14),
                    label: const Text('Edit Campaign'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showEditCampaignDialog(context, c);
                    },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(
                    icon: Icon(isActive ? LucideIcons.pause : LucideIcons.play, size: 14),
                    label: Text(isActive ? 'Pause Campaign' : 'Activate Campaign'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Campaign ${isActive ? 'paused' : 'activated'}'), backgroundColor: AppColors.primary));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: isActive ? AppColors.amber : AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  )),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _showEditCampaignDialog(BuildContext context, dynamic c) {
    final titleC = TextEditingController(text: c.title.toString());
    final descC = TextEditingController(text: c.desc.toString());
    final datesC = TextEditingController(text: c.dates.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(LucideIcons.edit, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Text('Edit Campaign', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        ]),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Campaign Title', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: descC, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: datesC, decoration: const InputDecoration(labelText: 'Validity Dates', border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Campaign "${titleC.text}" updated successfully'), backgroundColor: AppColors.primary));
              // In production, trigger provider to post the update
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final isActive = c.status.toLowerCase() == 'active';
    final statusColor = isActive ? AppColors.primary : AppColors.textTertiary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _showCampaignDetails(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovered ? AppColors.purple.withValues(alpha: 0.3) : AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: statusColor.withValues(alpha: 0.3))),
                child: Text(c.status.toString().toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const Icon(LucideIcons.moreHorizontal, size: 16, color: AppColors.textTertiary),
            ]),
            const SizedBox(height: 12),
            Text(c.title.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(c.desc.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(LucideIcons.gift, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('${c.redemptions} used', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ]),
              Row(children: [
                const Icon(LucideIcons.calendar, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(c.dates.toString(), style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _KpiCard extends StatefulWidget {
  final String label, value; final IconData icon; final Color accent;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.accent});
  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hovered ? widget.accent.withValues(alpha: 0.2) : AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 2, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: widget.accent, borderRadius: BorderRadius.circular(1), boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.4), blurRadius: 6)])),
          Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: widget.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(widget.icon, size: 14, color: widget.accent)),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.6))),
          ]),
          const SizedBox(height: 12),
          Text(widget.value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}
