import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../payment/screens/wallet_screen.dart';
import './analytics_dashboard_screen.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  void _handleImageAction() {
    final user = ref.read(authProvider).user;
    final hasImage =
        user?.profilePicture != null && user!.profilePicture!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.uploadCloud),
              title: const Text('Upload New Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndProcessImage();
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: Colors.red),
                title: const Text('Remove Current Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemoval();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndProcessImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    if (kIsWeb) {
      if (!mounted) return;
      _showUploadConfirmation(pickedFile);
    } else {
      final compressedFile = await _compressImage(File(pickedFile.path));
      if (compressedFile == null) return;

      if (!mounted) return;
      _showUploadConfirmation(XFile(compressedFile.path));
    }
  }

  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 512,
      minHeight: 512,
      quality: 85,
    );

    return result != null ? File(result.path) : null;
  }

  void _showUploadConfirmation(XFile file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Preview Photo",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipOval(
                  child: kIsWeb
                      ? Image.network(file.path, fit: BoxFit.cover)
                      : Image.file(File(file.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Looking good! Would you like to use this photo for your profile?",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        "Discard",
                        style: GoogleFonts.outfit(
                            color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _uploadAvatar(file);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "Save Photo",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadAvatar(XFile file) async {
    try {
      await ref.read(profileProvider.notifier).uploadProfilePicture(file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _confirmRemoval() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Photo"),
        content:
            const Text("Are you sure you want to remove your profile photo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeAvatar();
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeAvatar() async {
    try {
      await ref.read(profileProvider.notifier).removeProfilePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo removed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removal failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);

    if (user == null && authState.isAuthenticated && profileState.isLoading) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppTheme.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("Connecting...",
                    style: GoogleFonts.outfit(
                        fontSize: 16, color: Colors.white70)),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryBlue)),
              ),
            ),
            const SliverToBoxAdapter(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SkeletonLoader(
                      height: 100, width: double.infinity, borderRadius: 24),
                  SizedBox(height: 16),
                  SkeletonLoader(
                      height: 100, width: double.infinity, borderRadius: 24),
                ],
              ),
            )),
          ],
        ),
      );
    }

    if (user == null) {
      // If still authenticated, profile just failed to load — offer retry
      if (authState.isAuthenticated) {
        return Scaffold(
          backgroundColor:
              isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.wifiOff, size: 56, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    "Couldn't load profile",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Check your connection and try again.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(profileProvider.notifier).loadProfile(),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.userX, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  "Session unavailable",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please sign in again to load your customer profile.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                  child: const Text(
                    "Go to Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (profileState.error != null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.wifiOff, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Connection Error",
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Could not connect to the server (Timeout). Please check your laptop IP and connection.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).refreshUser();
                    ref.read(profileProvider.notifier).loadProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Retry Connection",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: ResponsiveWrapper(
        maxWidth: Responsive.contentMaxWidth(context),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(context, user, isDark),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Column(
                  children: [
                    _buildSection(
                        context,
                        "Profile & Security",
                        [
                          _profileMenuItem(
                              LucideIcons.user,
                              "Personal Information",
                              "Manage your details",
                              isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.personalInfo)),
                          _profileMenuItem(
                              LucideIcons.shieldCheck,
                              "KYC Verification",
                              user.kycStatus ?? "Pending",
                              isDark,
                              trailing: _buildStatusBadge(
                                  user.kycStatus ?? "PENDING"),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.kyc)),
                          _profileMenuItem(
                              LucideIcons.lock,
                              "Security",
                              kIsWeb
                                  ? "Password & 2FA"
                                  : "Password & Biometrics",
                              isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.security)),
                        ],
                        isDark),
                    const SizedBox(height: 24),
                    _buildSection(
                        context,
                        "Preferences",
                        [
                          _profileMenuItem(
                            LucideIcons.moon,
                            "Dark Mode",
                            isDark
                                ? "OLED Dark enabled"
                                : "Luxury Light enabled",
                            isDark,
                            trailing: Switch.adaptive(
                              value: isDark,
                              activeTrackColor: AppTheme.primaryBlue,
                              onChanged: (v) => ref
                                  .read(themeModeProvider.notifier)
                                  .toggleTheme(v),
                            ),
                          ),
                          _profileMenuItem(LucideIcons.bell, "Notifications",
                              "Alerts & updates", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.notifications)),
                          _profileMenuItem(LucideIcons.languages, "Language",
                              "English (US)", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.language)),
                        ],
                        isDark),
                    const SizedBox(height: 24),
                    _buildSection(
                        context,
                        "Financial & Stats",
                        [
                          _profileMenuItem(LucideIcons.wallet, "My Wallet",
                              "Balance & transactions", isDark,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WalletScreen()))),
                          _profileMenuItem(LucideIcons.creditCard,
                              "Payment Methods", "Cards & UPI IDs", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.paymentMethods)),
                          _profileMenuItem(
                              LucideIcons.barChart,
                              "Personal Analytics",
                              "Spending & usage insights",
                              isDark,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AnalyticsDashboardScreen()))),
                        ],
                        isDark),
                    const SizedBox(height: 24),
                    _buildSection(
                        context,
                        "My Energy",
                        [
                          _profileMenuItem(LucideIcons.mapPin, "Addresses",
                              "Manage delivery points", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.addresses)),
                          _profileMenuItem(LucideIcons.battery, "My Rentals",
                              "Track active power", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.myRentals)),
                          _profileMenuItem(LucideIcons.shoppingBag,
                              "My Purchases", "History & invoices", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.myPurchases)),
                        ],
                        isDark),
                    const SizedBox(height: 24),
                    _buildSection(
                        context,
                        "Support & Legal",
                        [
                          _profileMenuItem(LucideIcons.helpCircle,
                              "Help Center", "FAQs & support", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.helpCenter)),
                          _profileMenuItem(LucideIcons.fileText,
                              "Terms of Service", "Our policies", isDark,
                              onTap: () =>
                                  Navigator.pushNamed(context, AppRoutes.terms)),
                          _profileMenuItem(LucideIcons.shield, "Privacy Policy",
                              "Data protection", isDark,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.privacy)),
                        ],
                        isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, User user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 265,
      pinned: true,
      backgroundColor: AppTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => _handleImageAction(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue[100],
                            backgroundImage: user.profilePicture != null
                                ? (user.profilePicture!.startsWith('/') ||
                                        user.profilePicture!.contains('cache')
                                    ? FileImage(File(user.profilePicture!))
                                        as ImageProvider
                                    : CachedNetworkImageProvider(user
                                            .profilePicture!
                                            .startsWith('http')
                                        ? user.profilePicture!
                                        : '${ApiConstants.baseUrl}${user.profilePicture}'))
                                : null,
                            child: user.profilePicture == null
                                ? const Icon(
                                    LucideIcons.user,
                                    size: 50,
                                    color: AppTheme.primaryBlue,
                                  )
                                : null,
                          ),
                          if (ref.watch(profileProvider).isAvatarUploading)
                            const CircularProgressIndicator(
                              color: AppTheme.primaryBlue,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onTap: () => _handleImageAction(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.camera,
                            size: 16, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user.fullName ?? "Premium User",
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                user.email ?? user.phoneNumber ?? "",
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.shadowLight,
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _profileMenuItem(
      IconData icon, String title, String subtitle, bool isDark,
      {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      trailing: trailing ??
          const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildStatusBadge(String status) {
    final isVerified = status == 'VERIFIED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            (isVerified ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isVerified ? Colors.green : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}
