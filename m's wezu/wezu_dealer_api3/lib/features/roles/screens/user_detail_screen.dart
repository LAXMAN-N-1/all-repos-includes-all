import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/users_service.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/models/dealer_user.dart';
import '../../../core/utils/time_utils.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DealerUser? _user;
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final uId = int.parse(widget.userId);
      final userData = await ref.read(usersServiceProvider).getUserDetail(uId);
      final userSessions = await ref.read(usersServiceProvider).getSessions(uId);
      
      setState(() {
        _user = DealerUser.fromJson(userData);
        _sessions = userSessions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ToastService.show(context, 'Failed to load user details: $e', type: ToastType.error);
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.transparent, body: Center(child: CircularProgressIndicator()));
    if (_user == null) return Scaffold(backgroundColor: Colors.transparent, body: Center(child: Text('User not found', style: TextStyle(color: Colors.white))));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.shellBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tabs
            Container(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textTertiary,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'General Info'),
                  Tab(text: 'Access & Permissions'),
                  Tab(text: 'Security & Logs'),
                ],
              ),
            ),

            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralInfo(),
                  _buildAccessPermissions(),
                  _buildSecurityLogs(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textSecondary),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(_user!.initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user!.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_user!.email, style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
              ],
            ),
          ),
          _StatusChip(status: _user!.status),
        ],
      ),
    );
  }

  Widget _buildGeneralInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('EMPLOYEE DETAILS', LucideIcons.user),
          const SizedBox(height: 24),
          _infoGrid([
            _InfoItem('Full Name', _user!.name),
            _InfoItem('Email Address', _user!.email),
            _InfoItem('Phone Number', _user!.phone ?? 'Not provided'),
            _InfoItem('Department', _user!.department ?? 'General'),
            _InfoItem('Designation Role', _user!.role),
            _InfoItem('Joined On', _formatJoinedDate(_user!.createdAt)),
          ]),
          const SizedBox(height: 48),
          _sectionHeader('INTERNAL NOTES', LucideIcons.fileText),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
            child: Text(_user?.department ?? 'No internal notes for this user.', 
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessPermissions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ASSIGNED STATIONS', LucideIcons.mapPin),
          const SizedBox(height: 16),
          _user!.stationIds.isEmpty 
            ? const Text('All Stations (Full Access)', style: TextStyle(color: AppColors.primary, fontSize: 14))
            : Wrap(
                spacing: 8, runSpacing: 8,
                children: _user!.stationIds.map((id) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                  child: Text('STATION #$id', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
          const SizedBox(height: 48),
          _sectionHeader('MODULE PERMISSIONS', LucideIcons.shieldCheck),
          const SizedBox(height: 24),
          _buildPermissionsList(),
        ],
      ),
    );
  }

  Widget _buildPermissionsList() {
    if (_user!.permissions.isEmpty) {
      return const Text('Inherited from Role: Dealer Admin', style: TextStyle(color: AppColors.textSecondary));
    }
    return Column(
      children: _user!.permissions.entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(child: Text(e.key.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
            Wrap(
              spacing: 4,
              children: e.value.map((p) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                child: Text(p, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              )).toList(),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSecurityLogs() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('LOGIN SECURITY', LucideIcons.lock),
          const SizedBox(height: 24),
          _infoGrid([
            _InfoItem('Failed Attempts', '0'),
            _InfoItem('Account Status', _user!.status.toUpperCase()),
            _InfoItem('Two-Factor Auth', 'Disabled'),
            _InfoItem('Password Changed', 'Never'),
          ]),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('ACTIVE SESSIONS', LucideIcons.monitor),
              TextButton(
                onPressed: () {},
                child: const Text('Terminate All', style: TextStyle(color: AppColors.red, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sessions.isEmpty 
            ? const Text('No active sessions found.', style: TextStyle(color: AppColors.textTertiary))
            : Column(
                children: _sessions.map((s) => _SessionTile(session: s)).toList(),
              ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _infoGrid(List<Widget> items) {
    return Wrap(
      spacing: 40, runSpacing: 24,
      children: items,
    );
  }

  String _formatJoinedDate(String? iso) {
    final formatted = TimeUtils.dateOnly(iso);
    return formatted == '—' ? 'N/A' : formatted;
  }
}

class _InfoItem extends StatelessWidget {
  final String label, value;
  const _InfoItem(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? AppColors.primary : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;
  const _SessionTile({required this.session});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(LucideIcons.chrome, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session['device'] ?? 'Unknown Browser', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(session['ip'] ?? 'Unknown IP', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Text(session['last_active'] ?? 'Recent', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
