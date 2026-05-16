import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/payment_method_model.dart';
import '../../../repositories/payment_method_repository.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const _accent = Color(0xFFFD802E);
  static const _dark = Color(0xFF233D4C);

  @override
  void initState() {
    super.initState();
    // Fetch on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentMethodRepository>().fetchMethods();
    });
  }

  // ─── Delete flow ───────────────────────────────────────────────────────────

  Future<void> _confirmDelete(
    BuildContext ctx,
    PaymentMethodRepository repo,
    PaymentMethod method,
  ) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Payment Method'),
        content: Text(
          'Remove "${method.displayName}" from your saved methods?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await repo.deleteMethod(method.id);
  }

  // ─── Add Method Sheet ──────────────────────────────────────────────────────

  void _showAddSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMethodSheet(
        onAddUpi: (upiId) async {
          await ctx.read<PaymentMethodRepository>().addUpiMethod(upiId);
        },
        onAddCard:
            ({
              required last4,
              required brand,
              required expiryMonth,
              required expiryYear,
            }) async {
              await ctx.read<PaymentMethodRepository>().addCardMethodMock(
                last4: last4,
                brand: brand,
                expiryMonth: expiryMonth,
                expiryYear: expiryYear,
              );
            },
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PaymentMethodRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        elevation: 0.5,
      ),
      body: Builder(
        builder: (ctx) {
          if (repo.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }

          if (repo.hasError && repo.methods.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 56,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    repo.error ?? 'Failed to load methods.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: repo.fetchMethods,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (repo.methods.isEmpty) {
            return _EmptyState(onAdd: () => _showAddSheet(ctx));
          }

          return RefreshIndicator(
            color: _accent,
            onRefresh: repo.fetchMethods,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Cards section ────────────────────────────────────────────
                _sectionLabel('Saved Cards'),
                const SizedBox(height: 8),
                ...repo.methods
                    .where((m) => m.type == PaymentMethodType.card)
                    .map(
                      (m) => _MethodTile(
                        method: m,
                        onDelete: () => _confirmDelete(ctx, repo, m),
                        onSetDefault: () => repo.setDefault(m.id),
                      ),
                    ),

                if (repo.methods.any(
                  (m) => m.type == PaymentMethodType.upi,
                )) ...[
                  const SizedBox(height: 16),
                  _sectionLabel('UPI IDs'),
                  const SizedBox(height: 8),
                  ...repo.methods
                      .where((m) => m.type == PaymentMethodType.upi)
                      .map(
                        (m) => _MethodTile(
                          method: m,
                          onDelete: () => _confirmDelete(ctx, repo, m),
                          onSetDefault: () => repo.setDefault(m.id),
                        ),
                      ),
                ],

                const SizedBox(height: 24),
                // ── Add new button ───────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () => _showAddSheet(ctx),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add New Method'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: _accent,
                    side: const BorderSide(color: _accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      floatingActionButton: repo.methods.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSheet(context),
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Method'),
            )
          : null,
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: _dark,
      letterSpacing: 0.3,
    ),
  );
}

// ─── Method Tile ──────────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.onDelete,
    required this.onSetDefault,
  });

  final PaymentMethod method;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    final isCard = method.type == PaymentMethodType.card;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: method.isDefault ? _accent : Colors.grey[200]!,
          width: method.isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Brand / type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isCard
                    ? _CardBrandIcon(brand: method.brand ?? CardBrand.unknown)
                    : const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 22,
                        color: Color(0xFF7C4DFF),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (method.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isCard && method.expiryLabel.isNotEmpty)
                    Text(
                      method.expiryLabel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  if (!method.isDefault) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onSetDefault,
                      child: const Text(
                        'Set as Default',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Delete
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red[400],
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card brand icon ───────────────────────────────────────────────────────────

class _CardBrandIcon extends StatelessWidget {
  const _CardBrandIcon({required this.brand});
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    switch (brand) {
      case CardBrand.visa:
        return const Text(
          'VISA',
          style: TextStyle(
            color: Color(0xFF1A1F71),
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        );
      case CardBrand.mastercard:
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEB001B),
                ),
              ),
            ),
            Positioned(
              right: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        );
      case CardBrand.rupay:
        return const Text(
          'RuPay',
          style: TextStyle(
            color: Color(0xFF006A4E),
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        );
      case CardBrand.amex:
        return const Text(
          'AMEX',
          style: TextStyle(
            color: Color(0xFF007BC1),
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        );
      default:
        return const Icon(
          Icons.credit_card_rounded,
          size: 22,
          color: Colors.grey,
        );
    }
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;
  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_off_rounded,
                size: 56,
                color: _accent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Saved Methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233D4C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add a card or UPI ID to pay faster next time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Method Bottom Sheet ──────────────────────────────────────────────────

typedef _AddCardCallback =
    Future<void> Function({
      required String last4,
      required CardBrand brand,
      required String expiryMonth,
      required String expiryYear,
    });

class _AddMethodSheet extends StatefulWidget {
  const _AddMethodSheet({required this.onAddUpi, required this.onAddCard});
  final Future<void> Function(String upiId) onAddUpi;
  final _AddCardCallback onAddCard;

  @override
  State<_AddMethodSheet> createState() => _AddMethodSheetState();
}

class _AddMethodSheetState extends State<_AddMethodSheet> {
  static const _accent = Color(0xFFFD802E);
  static const _dark = Color(0xFF233D4C);

  bool _isCardMode = true;
  bool _isSaving = false;

  // Card fields
  final _last4Controller = TextEditingController();
  final _expiryController = TextEditingController(); // MM/YY
  CardBrand _selectedBrand = CardBrand.visa;

  // UPI field
  final _upiController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _last4Controller.dispose();
    _expiryController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    if (_isCardMode) {
      final parts = _expiryController.text.split('/');
      await widget.onAddCard(
        last4: _last4Controller.text.trim(),
        brand: _selectedBrand,
        expiryMonth: parts[0].trim(),
        expiryYear: '20${parts[1].trim()}',
      );
    } else {
      await widget.onAddUpi(_upiController.text.trim());
    }
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _dark,
              ),
            ),
            const SizedBox(height: 16),

            // Mode toggle
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _SheetTab(
                    label: '💳  Card',
                    isSelected: _isCardMode,
                    onTap: () => setState(() => _isCardMode = true),
                  ),
                  _SheetTab(
                    label: '📲  UPI',
                    isSelected: !_isCardMode,
                    onTap: () => setState(() => _isCardMode = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card form
            if (_isCardMode) ...[
              // Brand dropdown
              DropdownButtonFormField<CardBrand>(
                value: _selectedBrand,
                decoration: _dec('Card Network'),
                items: const [
                  DropdownMenuItem(value: CardBrand.visa, child: Text('Visa')),
                  DropdownMenuItem(
                    value: CardBrand.mastercard,
                    child: Text('Mastercard'),
                  ),
                  DropdownMenuItem(
                    value: CardBrand.rupay,
                    child: Text('RuPay'),
                  ),
                  DropdownMenuItem(value: CardBrand.amex, child: Text('Amex')),
                ],
                onChanged: (v) => setState(() => _selectedBrand = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _last4Controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: _dec('Last 4 digits'),
                validator: (v) => (v == null || v.length != 4)
                    ? 'Enter the last 4 digits'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                decoration: _dec('Expiry (MM/YY)'),
                onChanged: (v) {
                  if (v.length == 2 && !v.contains('/')) {
                    _expiryController.text = '$v/';
                    _expiryController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _expiryController.text.length),
                    );
                  }
                },
                validator: (v) {
                  if (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                    return 'Enter expiry as MM/YY';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '💡 In production, card details would be tokenised via a payment gateway SDK and never stored here.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
            ],

            // UPI form
            if (!_isCardMode) ...[
              TextFormField(
                controller: _upiController,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('UPI ID (e.g. name@upi)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter UPI ID';
                  if (!RegExp(
                    r'^[\w.\-]{2,256}@[a-zA-Z]{2,64}$',
                  ).hasMatch(v.trim())) {
                    return 'Enter a valid UPI ID';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Method',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _accent, width: 1.5),
    ),
    filled: true,
    fillColor: Colors.white,
  );
}

class _SheetTab extends StatelessWidget {
  const _SheetTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? _accent : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
