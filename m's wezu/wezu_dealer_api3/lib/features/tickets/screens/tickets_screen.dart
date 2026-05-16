import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/tickets_provider.dart';
import '../models/ticket_state.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});
  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _splitController;
  late final AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int _selectedFilterIndex = 0;
  final Set<int> _selectedTicketIds = {};
  bool _isBulkActionVisible = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _splitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _splitController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketsProvider);
    final isDetailOpen = state.selectedTicketId != null;

    // Animate the split transition
    if (isDetailOpen) {
      _splitController.forward();
    } else {
      _splitController.reverse();
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          final entryProgress =
              Curves.easeOut.transform(_entryController.value);
          return Opacity(
            opacity: entryProgress,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - entryProgress)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            _buildTopControls(state),
            _buildMetricsStrip(state),
            Expanded(
              child: Stack(
                children: [
                  if (state.isMetricsView)
                    _buildMetricsDashboard(state)
                  else
                    AnimatedBuilder(
                      animation: _splitController,
                      builder: (context, child) {
                        final splitValue =
                            Curves.easeInOut.transform(_splitController.value);
                        final screenWidth = MediaQuery.of(context).size.width;

                        return Row(
                          children: [
                            // Left Panel (List)
                            Expanded(
                              flex: (100 - (45 * splitValue)).toInt(),
                              child: _buildTicketsList(state),
                            ),
                            // Right Panel (Detail)
                            if (splitValue >
                                0.01) // Prevent hit-testing very small widths
                              Container(
                                width: screenWidth * 0.45 * splitValue,
                                decoration: const BoxDecoration(
                                  border: Border(
                                      left:
                                          BorderSide(color: AppColors.border)),
                                ),
                                child: _buildTicketDetail(state),
                              ),
                          ],
                        );
                      },
                    ),
                  if (state.isFilterPanelOpen) _buildAdvancedFilterPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(TicketState state) {
    final filters = [
      'All',
      'Open',
      'In Progress',
      'Resolved',
      'Closed',
      'Escalated'
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Filter Pills (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(filters.length, (index) {
                  final label = filters[index];
                  final isSelected = _selectedFilterIndex == index;
                  final count = label == 'All'
                      ? state.tickets.length
                      : state.tickets
                          .where((t) =>
                              t.status.toLowerCase() == label.toLowerCase())
                          .length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedFilterIndex = index);
                        ref
                            .read(ticketsProvider.notifier)
                            .refresh(statusFilter: label);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getStatusColor(label)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? _getStatusColor(label)
                                  : AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : AppColors.cardBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right Side Controls (Fixed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width:
                    240, // Slightly reduced width to ensure fit on smaller screens
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search ticket ID, subject, customer...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    prefixIcon: Icon(LucideIcons.search,
                        size: 16, color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _iconButton(
                  state.isMetricsView
                      ? LucideIcons.layoutList
                      : LucideIcons.barChart2,
                  () => ref.read(ticketsProvider.notifier).toggleMetricsView()),
              const SizedBox(width: 12),
              _iconButton(LucideIcons.filter,
                  () => ref.read(ticketsProvider.notifier).toggleFilterPanel()),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showNewTicketDrawer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('New Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsStrip(TicketState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: state.metrics
            .map(
              (m) => Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            m.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            m.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _getColor(m.color),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (m.trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getColor(m.color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          m.trend!,
                          style: TextStyle(
                            color: _getColor(m.color),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Color _getColor(String name) {
    switch (name) {
      case 'amber':
        return AppColors.amber;
      case 'cyan':
        return AppColors.cyan;
      case 'red':
        return AppColors.red;
      case 'green':
        return AppColors.primary;
      default:
        return AppColors.textPrimary;
    }
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
      ),
    );
  }

  Widget _highlightText(String text, String query, TextStyle baseStyle) {
    if (query.isEmpty) return Text(text, style: baseStyle);

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    if (matches.isEmpty) return Text(text, style: baseStyle);

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: baseStyle.copyWith(
            backgroundColor: AppColors.primary.withOpacity(0.3),
            color: Colors.white),
      ));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildTicketsList(TicketState state) {
    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));

    final filters = ['All', 'Open', 'In Progress', 'Resolved', 'Closed'];
    final selectedFilter = filters[_selectedFilterIndex];
    final searchQuery = _searchController.text.toLowerCase();

    final filteredTickets = state.tickets.where((t) {
      final matchesStatus =
          selectedFilter == 'All' || t.status == selectedFilter;
      final matchesSearch = searchQuery.isEmpty ||
          t.subject.toLowerCase().contains(searchQuery) ||
          t.id.toString().contains(searchQuery) ||
          t.customerName.toLowerCase().contains(searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(filteredTickets.length),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return _TicketRow(
                        ticket: ticket,
                        isSelected: state.selectedTicketId == ticket.id,
                        isCheckmarked: _selectedTicketIds.contains(ticket.id),
                        searchQuery: searchQuery,
                        onTap: () => ref
                            .read(ticketsProvider.notifier)
                            .selectTicket(ticket.id),
                        onToggleCheck: (val) {
                          setState(() {
                            if (val == true)
                              _selectedTicketIds.add(ticket.id);
                            else
                              _selectedTicketIds.remove(ticket.id);
                            _isBulkActionVisible =
                                _selectedTicketIds.isNotEmpty;
                          });
                        },
                        pulseController: _pulseController,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isBulkActionVisible) _buildBulkActionBar(),
      ],
    );
  }

  Widget _buildBulkActionBar() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.primary),
            boxShadow: [
              BoxShadow(
                  color: Colors.black45,
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_selectedTicketIds.length} tickets selected',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 24),
              _bulkActionItem(LucideIcons.userPlus, 'Assign', () {}),
              _bulkActionItem(LucideIcons.rotateCcw, 'Status', () {}),
              _bulkActionItem(LucideIcons.alertCircle, 'Priority', () {}),
              _bulkActionItem(LucideIcons.checkSquare, 'Close', () {}),
              const SizedBox(width: 12),
              IconButton(
                  icon: const Icon(LucideIcons.x,
                      size: 18, color: AppColors.textTertiary),
                  onPressed: () => setState(() {
                        _selectedTicketIds.clear();
                        _isBulkActionVisible = false;
                      })),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulkActionItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: _selectedTicketIds.length == count && count > 0,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    final allIds = ref
                        .read(ticketsProvider)
                        .tickets
                        .map((t) => t.id)
                        .toSet();
                    _selectedTicketIds.addAll(allIds);
                  } else {
                    _selectedTicketIds.clear();
                  }
                  _isBulkActionVisible = _selectedTicketIds.isNotEmpty;
                });
              },
              activeColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          _headerCell('Ticket', 100),
          _headerCell('Subject', 180),
          _headerCell('Customer', 140),
          _headerCell('Priority', 100),
          _headerCell('Assigned To', 120),
          _headerCell('Status', 110),
          _headerCell('SLA', 100),
          _headerCell('Created', 100),
          const SizedBox(
              width: 100,
              child: Text('Actions',
                  style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(label,
          style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTicketDetail(TicketState state) {
    final ticket =
        state.tickets.firstWhere((t) => t.id == state.selectedTicketId);
    return Container(
      color: AppColors.shellBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildDetailHeader(ticket),
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const TabBar(
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 3,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                              tabs: [
                                Tab(text: 'Conversation'),
                                Tab(text: 'Details'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildConversationTab(ticket),
                                  _buildDetailsTab(ticket),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildReplyComposer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTab(TicketDto ticket) {
    final items = [
      ...ticket.messages
          .map((m) => {'type': 'message', 'data': m, 'time': m.timestamp}),
      ...ticket.statusHistory
          .map((s) => {'type': 'status', 'data': s, 'time': s.timestamp}),
    ];
    items.sort(
        (a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'status') {
          return _buildStatusChangeMarker(item['data'] as StatusChangeEvent);
        }
        return _buildChatMessage(item['data'] as TicketMessage);
      },
    );
  }

  Widget _buildStatusChangeMarker(StatusChangeEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: _getColor(event.dotColor), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(event.description,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(event.timestamp),
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(TicketMessage msg) {
    final isCustomer = msg.type == 'customer';
    final isNote = msg.type == 'note';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isNote
            ? CrossAxisAlignment.stretch
            : (isCustomer ? CrossAxisAlignment.start : CrossAxisAlignment.end),
        children: [
          Row(
            mainAxisAlignment: isNote
                ? MainAxisAlignment.start
                : (isCustomer
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end),
            children: [
              if (isCustomer || isNote)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: (isNote
                          ? AppColors.amber
                          : (isCustomer ? AppColors.amber : AppColors.primary))
                      .withOpacity(0.1),
                  child: Text(msg.senderAvatar,
                      style: TextStyle(
                          color: isNote
                              ? AppColors.amber
                              : (isCustomer
                                  ? AppColors.amber
                                  : AppColors.primary),
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 8),
              Text(msg.senderName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              if (isNote) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.lock, size: 10, color: AppColors.amber),
                      SizedBox(width: 4),
                      Text('Internal Note',
                          style: TextStyle(
                              color: AppColors.amber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              if (!isCustomer && !isNote) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(msg.senderAvatar,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints:
                BoxConstraints(maxWidth: isNote ? double.infinity : 340),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isNote
                  ? AppColors.amber.withOpacity(0.05)
                  : (isCustomer
                      ? AppColors.cardBg
                      : AppColors.primary.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                top: BorderSide(
                    color: isNote
                        ? AppColors.amber.withOpacity(0.2)
                        : (isCustomer
                            ? AppColors.border
                            : AppColors.primary.withOpacity(0.1))),
                right: BorderSide(
                    color: isNote
                        ? AppColors.amber.withOpacity(0.2)
                        : (isCustomer
                            ? AppColors.border
                            : AppColors.primary.withOpacity(0.1))),
                bottom: BorderSide(
                    color: isNote
                        ? AppColors.amber.withOpacity(0.2)
                        : (isCustomer
                            ? AppColors.border
                            : AppColors.primary.withOpacity(0.1))),
                left: BorderSide(
                  color: isCustomer
                      ? AppColors.amber
                      : (isNote ? AppColors.amber : AppColors.primary),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isNote ? AppColors.warningText : Colors.white,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('MMM dd, HH:mm').format(msg.timestamp),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(TicketDto ticket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailSection('General Info', [
            _detailItem('Ticket ID', '#${ticket.id}'),
            _detailItem(
                'Created',
                DateFormat('MMM dd, yyyy HH:mm')
                    .format(DateTime.parse(ticket.createdAt).toLocal())),
            _detailItem('Source', ticket.sourceChannel),
            _detailItem('Reporter', ticket.customerName),
            _detailItem('Assigned To', ticket.assignedToName ?? 'Unassigned'),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const SizedBox(
                      width: 120,
                      child: Text('Tags',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12))),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children:
                          (ticket.tags.isEmpty ? ['No Tags'] : ticket.tags)
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: AppColors.border,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(tag,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 10)),
                                  ))
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _detailSection('Asset Details', [
            if (ticket.stationName != null)
              _detailItem('Station', ticket.stationName!),
            if (ticket.batteryId != null)
              _detailItem('Battery ID', ticket.batteryId!),
            if (ticket.transactionId != null)
              _detailItem('Transaction', ticket.transactionId!),
            _detailItem('Category', ticket.category),
            _detailItem('Priority', ticket.priority),
          ]),
          const SizedBox(height: 32),
          _detailSection('Customer History', [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  _pastTicketSummary('TKT-8488', 'Payment failed...',
                      'Resolved', AppColors.primary),
                  const Divider(color: AppColors.border, height: 24),
                  _pastTicketSummary('TKT-8120', 'Battery not charging',
                      'Closed', AppColors.textTertiary),
                  const Divider(color: AppColors.border, height: 24),
                  _pastTicketSummary('TKT-7950', 'Station Offline', 'Resolved',
                      AppColors.primary),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _detailSection('Related Tickets', [
            _relatedTicketItem('TKT-8488', 'Payment failed...', 'High'),
            _relatedTicketItem('TKT-8430', 'Station Offline', 'Medium'),
          ]),
        ],
      ),
    );
  }

  Widget _pastTicketSummary(
      String id, String subject, String status, Color statusColor) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(id,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.cyan,
                    fontSize: 11)),
            const SizedBox(height: 4),
            Text(subject,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const Spacer(),
        _simpleBadge(status, statusColor),
      ],
    );
  }

  Widget _relatedTicketItem(String id, String subject, String priority) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Text(id,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.cyan,
                    fontSize: 11)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(subject,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            _simpleBadge(priority, _getPriorityColor(priority)),
          ],
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(TicketDto ticket) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.shellBg,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${ticket.id}',
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              _iconButton(LucideIcons.edit2, () {},
                  color: AppColors.textSecondary),
              const SizedBox(width: 8),
              _iconButton(LucideIcons.arrowUpCircle, () {},
                  color: AppColors.amber),
              const SizedBox(width: 8),
              const _TicketActionMenu(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ticket.subject,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _simpleBadge(ticket.status, _getStatusColor(ticket.status)),
                const SizedBox(width: 8),
                _simpleBadge(
                    ticket.priority, _getPriorityColor(ticket.priority)),
                const SizedBox(width: 8),
                _simpleBadge(ticket.category, AppColors.purple),
                const SizedBox(width: 8),
                _simpleBadge(ticket.isResolved ? 'Resolved' : 'Within SLA',
                    ticket.isCritical ? AppColors.red : AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  bool _isReplyToCustomer = true;

  Widget _buildReplyComposer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: AppColors.shellBg,
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(
        children: [
          Row(
            children: [
              _composerTab(
                  'Reply to Customer',
                  _isReplyToCustomer,
                  AppColors.primary,
                  () => setState(() => _isReplyToCustomer = true)),
              const SizedBox(width: 12),
              _composerTab(
                  'Internal Note',
                  !_isReplyToCustomer,
                  AppColors.amber,
                  () => setState(() => _isReplyToCustomer = false)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _isReplyToCustomer
                        ? AppColors.border
                        : AppColors.amber.withOpacity(0.3))),
            child: TextField(
              controller: _replyController,
              maxLines: 3,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, height: 1.5),
              decoration: InputDecoration(
                  hintText: _isReplyToCustomer
                      ? 'Type your reply...'
                      : 'Type an internal note...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _iconButton(LucideIcons.paperclip, () {},
                  color: AppColors.textTertiary),
              const SizedBox(width: 8),
              _iconButton(LucideIcons.smile, () {},
                  color: AppColors.textTertiary),
              const SizedBox(width: 8),
              _iconButton(LucideIcons.zap, () {},
                  color: AppColors.textTertiary),
              const Spacer(),
              _isReplyToCustomer
                  ? OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Close Ticket'),
                    )
                  : const SizedBox(),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  final ticketId = ref.read(ticketsProvider).selectedTicketId;
                  if (ticketId != null && _replyController.text.isNotEmpty) {
                    await ref
                        .read(ticketsProvider.notifier)
                        .replyToTicket(ticketId, _replyController.text);
                    if (mounted) {
                      _replyController.clear();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isReplyToCustomer ? AppColors.primary : AppColors.amber,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_isReplyToCustomer ? 'Send Reply' : 'Add Note',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _composerTab(
      String label, bool active, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? color : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAdvancedFilterPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: const Border(bottom: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 20))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.filter,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Advanced Filters',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    icon: const Icon(LucideIcons.x,
                        size: 18, color: AppColors.textTertiary),
                    onPressed: () =>
                        ref.read(ticketsProvider.notifier).toggleFilterPanel()),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Priority',
                          style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Low', 'Medium', 'High', 'Critical']
                            .map((p) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _simpleBadge(p, _getPriorityColor(p)),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      const Text('Category',
                          style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Hardware Issue',
                          'Software Bug',
                          'Payment Problem',
                          'Battery Fault',
                          'Station Offline',
                          'Customer Complaint',
                          'General Inquiry'
                        ]
                            .map((cat) => FilterChip(
                                  label: Text(cat,
                                      style: const TextStyle(fontSize: 11)),
                                  selected: false,
                                  onSelected: (_) {},
                                  backgroundColor: AppColors.pageBg,
                                  selectedColor:
                                      AppColors.primary.withOpacity(0.1),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: const TextStyle(
                                      color: AppColors.textSecondary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: const BorderSide(
                                          color: AppColors.border)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterDropdown(
                          'Date Range', 'Last 32 Days', double.infinity),
                      const SizedBox(height: 24),
                      _filterDropdown(
                          'Assigned To', 'All Agents', double.infinity),
                      const SizedBox(height: 24),
                      _filterDropdown(
                          'Station Filter', 'All Stations', double.infinity),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {},
                    child: const Text('Reset Filters',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13))),
                const SizedBox(width: 24),
                ElevatedButton(
                    onPressed: () =>
                        ref.read(ticketsProvider.notifier).toggleFilterPanel(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Apply Results',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown(String label, String value, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: AppColors.pageBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              const Spacer(),
              const Icon(LucideIcons.chevronDown,
                  size: 14, color: AppColors.textTertiary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsDashboard(TicketState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Analytics',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Row(
            children: [
              _kpiTile('Open Tickets', '142', '+12%', AppColors.amber),
              const SizedBox(width: 24),
              _kpiTile('Avg Resolution', '4h 32m', '-15%', AppColors.cyan),
              const SizedBox(width: 24),
              _kpiTile('SLA Compliance', '98.5%', '+0.4%', AppColors.primary),
              const SizedBox(width: 24),
              _kpiTile('CSAT Rating', '4.8 / 5', '+2.1%', AppColors.primary),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: _buildChartCard(
                      'Ticket Volume Trends', 0, _buildSparkline())),
              const SizedBox(width: 24),
              Expanded(
                  flex: 2,
                  child: _buildChartCard(
                      'Status Distribution', 0, _buildDonutChart())),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(flex: 3, child: _buildPerformanceTable()),
              const SizedBox(width: 24),
              Expanded(
                  flex: 2,
                  child: _buildChartCard(
                      'Category Breakdown', 0, _buildBarChart())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiTile(String label, String value, String trend, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(trend,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, double width, Widget chart) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildSparkline() {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _SparklinePainter(),
    );
  }

  Widget _buildDonutChart() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _DonutChartPainter(),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('142',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text('Tickets',
                  style:
                      TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Column(
      children: [
        _barRow('Hardware Issue', 0.8, AppColors.amber),
        _barRow('Software Bug', 0.6, AppColors.cyan),
        _barRow('Payment Problem', 0.45, AppColors.primary),
        _barRow('Battery Fault', 0.7, AppColors.red),
      ],
    );
  }

  Widget _barRow(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              Text('${(percent * 100).toInt()}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Performing Agents',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _perfRow('Rama Koti', '42 Resolved', '98.2%', true),
          _perfRow('Suresh P', '38 Resolved', '95.5%', false),
          _perfRow('Ani S', '31 Resolved', '92.1%', false),
        ],
      ),
    );
  }

  Widget _perfRow(String name, String solved, String rate, bool isTop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          CircleAvatar(
              radius: 14,
              backgroundColor:
                  isTop ? AppColors.primary.withOpacity(0.2) : AppColors.border,
              child: Text(name[0],
                  style: TextStyle(
                      color: isTop ? AppColors.primary : Colors.white,
                      fontSize: 12))),
          const SizedBox(width: 12),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(solved,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 24),
          Text(rate,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showNewTicketDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: AppColors.pageBg,
            child: Container(
              width: 580,
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              child: _NewTicketForm(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    );
  }
}

class _TicketActionMenu extends StatelessWidget {
  const _TicketActionMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreHorizontal,
          size: 16, color: AppColors.textTertiary),
      color: AppColors.cardBg,
      offset: const Offset(0, 30),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border)),
      itemBuilder: (context) => [
        _buildMenuItem('Change Status', LucideIcons.rotateCcw),
        _buildMenuItem('Change Priority', LucideIcons.alertCircle),
        _buildMenuItem('Escalate', LucideIcons.arrowUpCircle),
        _buildMenuItem('Link Transaction', LucideIcons.link),
        const PopupMenuDivider(height: 1),
        _buildMenuItem('Mark Spam', LucideIcons.shieldAlert),
        _buildMenuItem('Delete', LucideIcons.trash2, color: AppColors.red),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String label, IconData icon,
      {Color? color}) {
    return PopupMenuItem(
      height: 36,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(color: color ?? Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

Color _getPriorityColor(String p) {
  switch (p.toLowerCase()) {
    case 'critical':
      return AppColors.red;
    case 'high':
      return AppColors.amber;
    case 'medium':
      return AppColors.cyan;
    default:
      return AppColors.textTertiary;
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'open':
      return AppColors.amber;
    case 'in progress':
      return AppColors.cyan;
    case 'resolved':
      return AppColors.primary;
    case 'escalated':
      return AppColors.red;
    default:
      return AppColors.border;
  }
}

class _TicketRow extends StatefulWidget {
  final TicketDto ticket;
  final bool isSelected;
  final bool isCheckmarked;
  final String searchQuery;
  final VoidCallback onTap;
  final Function(bool?) onToggleCheck;
  final AnimationController pulseController;

  const _TicketRow({
    required this.ticket,
    required this.isSelected,
    required this.isCheckmarked,
    required this.searchQuery,
    required this.onTap,
    required this.onToggleCheck,
    required this.pulseController,
  });

  @override
  State<_TicketRow> createState() => _TicketRowState();
}

class _TicketRowState extends State<_TicketRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ticketsScreen =
        context.findAncestorStateOfType<_TicketsScreenState>();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          constraints:
              const BoxConstraints(minHeight: 64), // Ensure hit-testable area
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.05)
                : (_isHovered
                    ? AppColors.primary.withOpacity(0.02)
                    : Colors.transparent),
            border: Border(
              bottom: const BorderSide(color: AppColors.border),
              left: BorderSide(
                color: (widget.isSelected || _isHovered)
                    ? _getStatusColor(widget.ticket.status)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: widget.isCheckmarked,
                  onChanged: widget.onToggleCheck,
                  activeColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              // Ticket ID & Category
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ticketsScreen?._highlightText(
                            '#${widget.ticket.id}',
                            widget.searchQuery,
                            const TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.cyan,
                                fontSize: 12)) ??
                        Text('#${widget.ticket.id}',
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.cyan,
                                fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(widget.ticket.category,
                          style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              // Subject & Description
              SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ticketsScreen?._highlightText(
                            widget.ticket.subject,
                            widget.searchQuery,
                            const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)) ??
                        Text(widget.ticket.subject,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                    Text(widget.ticket.description,
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ],
                ),
              ),
              // Customer
              SizedBox(
                width: 140,
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(widget.ticket.customerAvatar,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ticketsScreen?._highlightText(
                                  widget.ticket.customerName,
                                  widget.searchQuery,
                                  const TextStyle(
                                      color: Colors.white, fontSize: 13)) ??
                              Text(widget.ticket.customerName,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                          Text(widget.ticket.customerPhone,
                              style: const TextStyle(
                                  color: AppColors.textTertiary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Priority
              SizedBox(
                width: 100,
                child: _buildPriorityBadge(widget.ticket.priority),
              ),
              // Assigned To
              SizedBox(
                width: 120,
                child: widget.ticket.assignedToName != null
                    ? Row(
                        children: [
                          CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.border,
                              child: Text(widget.ticket.assignedToAvatar ?? '?',
                                  style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(widget.ticket.assignedToName!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('Unassigned',
                                style: TextStyle(
                                    color: AppColors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            child: const Text('Assign',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
              ),
              // Status
              SizedBox(
                width: 110,
                child: _buildStatusBadge(widget.ticket.status),
              ),
              // SLA
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.ticket.isResolved ? 'Resolved' : '2h 14m',
                        style: TextStyle(
                            color: (widget.ticket.isCritical &&
                                    !widget.ticket.isResolved)
                                ? AppColors.red
                                : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    if (!widget.ticket.isResolved)
                      const Text('within SLA',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 10)),
                  ],
                ),
              ),
              // Created
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        DateFormat('MMM dd')
                            .format(DateTime.parse(widget.ticket.createdAt).toLocal()),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                    Text(
                        DateFormat('HH:mm')
                            .format(DateTime.parse(widget.ticket.createdAt).toLocal()),
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 10)),
                  ],
                ),
              ),
              // Actions
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    _tableIconButton(LucideIcons.reply, () {}),
                    const SizedBox(width: 8),
                    _tableIconButton(LucideIcons.userPlus, () {}),
                    const SizedBox(width: 4),
                    const _TicketActionMenu(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color = _getPriorityColor(priority);

    final isHigh = priority.toLowerCase() == 'critical' ||
        priority.toLowerCase() == 'high';

    return AnimatedBuilder(
      animation: widget.pulseController,
      builder: (context, child) {
        final pulse =
            isHigh ? (0.1 + (widget.pulseController.value * 0.1)) : 0.1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(pulse),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.rectangle,
                  boxShadow: isHigh
                      ? [
                          BoxShadow(
                              color: color,
                              blurRadius: 4 * widget.pulseController.value)
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 6),
              Text(priority,
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    IconData icon;
    Color color;
    switch (status.toLowerCase()) {
      case 'open':
        icon = LucideIcons.circle;
        color = AppColors.amber;
        break;
      case 'in progress':
        icon = LucideIcons.rotateCcw;
        color = AppColors.cyan;
        break;
      case 'resolved':
        icon = LucideIcons.checkCircle;
        color = AppColors.primary;
        break;
      case 'escalated':
        icon = LucideIcons.arrowUpCircle;
        color = AppColors.red;
        break;
      default:
        icon = LucideIcons.circle;
        color = AppColors.textTertiary;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class _NewTicketForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NewTicketForm> createState() => _NewTicketFormState();
}

class _NewTicketFormState extends ConsumerState<_NewTicketForm> {
  String? _selectedCategory;
  String _selectedPriority = 'Medium';
  String? _selectedStation;
  String? _selectedAssignee;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _transactionController = TextEditingController();
  final TextEditingController _batteryController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Hardware Issue', 'icon': LucideIcons.cpu},
    {'name': 'Software Bug', 'icon': LucideIcons.terminal},
    {'name': 'Payment Problem', 'icon': LucideIcons.creditCard},
    {'name': 'Battery Fault', 'icon': LucideIcons.batteryCharging},
    {'name': 'Station Offline', 'icon': LucideIcons.signalLow},
    {'name': 'Customer Complaint', 'icon': LucideIcons.userX},
    {'name': 'General Inquiry', 'icon': LucideIcons.helpCircle},
    {'name': 'Other', 'icon': LucideIcons.moreHorizontal},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drawer Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              const Text('Create New Ticket',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                  icon:
                      const Icon(LucideIcons.x, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        // Form Fields
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Subject'),
                _textField('e.g. Battery not charging at station #42',
                    controller: _subjectController),
                const SizedBox(height: 24),

                _label('Linked Customer (Search)'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                  child: TextField(
                    controller: _customerController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Type customer name or phone...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      prefixIcon: Icon(LucideIcons.search,
                          size: 14, color: AppColors.textTertiary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _label('Category'),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['name'];
                    return InkWell(
                      onTap: () => setState(
                          () => _selectedCategory = cat['name'] as String),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'] as IconData,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 24),
                            const SizedBox(height: 8),
                            Text(cat['name'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                _label('Priority'),
                Row(
                  children: ['Low', 'Medium', 'High', 'Critical'].map((p) {
                    final isSelected = _selectedPriority == p;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedPriority = p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _getPriorityColor(p)
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isSelected
                                      ? _getPriorityColor(p)
                                      : AppColors.border),
                            ),
                            child: Center(
                              child: Text(p,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedPriority == 'Critical')
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.red.withOpacity(0.2))),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.alertTriangle,
                            color: AppColors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                            'CRITICAL: This will trigger an immediate management alert.',
                            style: TextStyle(
                                color: AppColors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                if (_selectedCategory != null) ...[
                  _label('Linked Station'),
                  _dropdown([
                    'Electronic City Phase 1',
                    'HSR Layout Sector 2',
                    'Indiranagar 12th Main'
                  ], _selectedStation,
                      (v) => setState(() => _selectedStation = v)),
                  const SizedBox(height: 24),
                ],

                if (_selectedCategory == 'Payment Problem') ...[
                  _label('Linked Transaction ID'),
                  _textField('TXN_99210', controller: _transactionController),
                  const SizedBox(height: 24),
                ],

                if (_selectedCategory == 'Hardware Issue' ||
                    _selectedCategory == 'Battery Fault') ...[
                  _label('Battery Serial Number'),
                  _textField('e.g. WZ-BAT-001', controller: _batteryController),
                  const SizedBox(height: 24),
                ],

                _label('Attachments (Max 5 files, 10MB each)'),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle
                            .solid), // In a real app, use DottedBorder package
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.uploadCloud,
                          color: AppColors.textTertiary, size: 28),
                      const SizedBox(height: 8),
                      const Text('Drop files here or click to upload',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _label('Assign To'),
                _dropdown([
                  'Auto-assign',
                  'Rama Koti (Agent)',
                  'Suresh P (Agent)',
                  'Ani S (Lead)'
                ], _selectedAssignee ?? 'Auto-assign',
                    (v) => setState(() => _selectedAssignee = v)),
                const SizedBox(height: 24),

                _label('Description (Markdown supported)'),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: Row(
                          children: [
                            _toolbarIcon(LucideIcons.bold),
                            _toolbarIcon(LucideIcons.italic),
                            _toolbarIcon(LucideIcons.list),
                            _toolbarIcon(LucideIcons.code),
                            const Spacer(),
                            const Text('Markdown',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 10)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 6,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                              hintText: 'Provide detailed information...',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    const Icon(LucideIcons.lock,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    _label('Internal Notes'),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.amber.withOpacity(0.2))),
                  child: const TextField(
                    maxLines: 3,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                        hintText: 'Visible to agents only',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 40),

                // Submit Buttons
                Row(
                  children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side:
                                    const BorderSide(color: AppColors.border)),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: AppColors.textSecondary)))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_subjectController.text.isEmpty ||
                                _descriptionController.text.isEmpty) return;
                            final success = await ref
                                .read(ticketsProvider.notifier)
                                .createTicket(
                                  _subjectController.text,
                                  _descriptionController.text,
                                  _selectedCategory ?? 'General',
                                  _selectedPriority,
                                );
                            if (success && mounted) {
                              Navigator.pop(context);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Failed to create ticket')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Create Ticket',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _textField(String hint, {TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: InputBorder.none),
      ),
    );
  }

  Widget _toolbarIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Icon(icon, size: 16, color: AppColors.textSecondary),
    );
  }

  Widget _dropdown(
      List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cardBg,
          icon: const Icon(LucideIcons.chevronDown,
              size: 16, color: AppColors.textTertiary),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary.withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final points = [0.2, 0.4, 0.3, 0.7, 0.5, 0.9, 0.8];
    final dx = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
          Offset(i * dx, size.height * (1 - points[i])), 4, dotPaint);
      canvas.drawCircle(Offset(i * dx, size.height * (1 - points[i])), 2,
          Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Open
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -1.5,
        2.5,
        false,
        paint..color = AppColors.amber);
    // In Progress
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        1.1,
        1.5,
        false,
        paint..color = AppColors.cyan);
    // Resolved
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        2.7,
        2.0,
        false,
        paint..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
