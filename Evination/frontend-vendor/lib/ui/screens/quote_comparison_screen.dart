import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bid_model.dart';
import '../../theme/app_theme.dart';

class QuoteComparisonScreen extends ConsumerStatefulWidget {
  final int eventId; // Using eventId as the aggregator for quotes
  const QuoteComparisonScreen({super.key, required this.eventId});

  @override
  ConsumerState<QuoteComparisonScreen> createState() => _QuoteComparisonScreenState();
}

class _QuoteComparisonScreenState extends ConsumerState<QuoteComparisonScreen> {
  int? selectedQuoteId;

  @override
  Widget build(BuildContext context) {
    // Reusing eventBidsProvider which fetches *all* bids for the event
    final bidsAsync = ref.watch(eventBidsProvider(widget.eventId));

    return Scaffold(
      body: bidsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (quotes) {
          if (quotes.isEmpty) return const Center(child: Text('No quotes to compare'));
          
          final lowestPrice = quotes.map((q) => (q.amount - (q.discount ?? 0))).reduce((a, b) => a < b ? a : b);
          final highestRating = quotes.map((q) => q.vendorRating ?? 0).reduce((a, b) => a > b ? a : b);
          
          // Default select first recommended or first
          if (selectedQuoteId == null && quotes.isNotEmpty) {
             final recommended = quotes.where((q) => q.isRecommended == true);
             selectedQuoteId = recommended.isNotEmpty ? recommended.first.id : quotes.first.id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Quote Comparison', style: AppTheme.heading.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text('Compare quotes for Event #${widget.eventId}', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),

                // Quick Stats
                Row(
                  children: [
                    _QuickStat('Quotes Received', '${quotes.length}'),
                    const SizedBox(width: 16),
                    _QuickStat('Lowest Price', '₹${(lowestPrice/1000).toStringAsFixed(0)}K', color: Colors.green),
                    const SizedBox(width: 16),
                    _QuickStat('Best Rating', highestRating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 24),

                // Comparison Table
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: AppTheme.cardDecoration.boxShadow,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                      columnSpacing: 24,
                      columns: [
                        const DataColumn(label: Text('Criteria', style: TextStyle(fontWeight: FontWeight.bold))),
                        ...quotes.map((q) => DataColumn(label: _ColumnHeader(
                          quote: q, 
                          isSelected: selectedQuoteId == q.id,
                          onSelect: () => setState(() => selectedQuoteId = q.id)
                        ))),
                      ],
                      rows: [
                        _buildRow('Base Price', quotes, (q) => '₹${NumberFormat.decimalPattern().format(q.amount)}'),
                        _buildRow('Discount', quotes, (q) => q.discount != null && q.discount! > 0 ? '₹${NumberFormat.decimalPattern().format(q.discount)}' : '-', isDiscount: true),
                        _buildRow('Final Amount', quotes, (q) {
                           final finalAmt = q.amount - (q.discount ?? 0);
                           final isLowest = finalAmt == lowestPrice;
                           return _HighlightText(
                             '₹${NumberFormat.decimalPattern().format(finalAmt)}', 
                             isgood: isLowest
                           );
                        }),
                        _buildRow('Rating', quotes, (q) => _RatingCell(q.vendorRating ?? 0, isBest: (q.vendorRating ?? 0) == highestRating)),
                        _buildRow('Timeline', quotes, (q) => '${q.timelineDays ?? "-"} days'),
                        _buildRow('Valid Until', quotes, (q) => q.validUntil != null ? DateFormat('MMM dd, yyyy').format(q.validUntil!) : '-'),
                        // Advantages Row (Truncated)
                        DataRow(cells: [
                           const DataCell(Text('Advantages', style: TextStyle(color: Colors.grey))),
                           ...quotes.map((q) => DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: (q.advantages ?? []).take(2).map((a) => 
                                  Row(children: [
                                    const Icon(Icons.check, size: 14, color: Colors.green), 
                                    const SizedBox(width: 4), 
                                    Expanded(child: Text(a.toString(), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))
                                  ])
                                ).toList(),
                              )
                           ))
                        ]),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Detailed Cards (Grid)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 24, 
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.8, 
                  ),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quotes[index];
                    return _DetailedQuoteCard(
                      quote: quote,
                      isSelected: selectedQuoteId == quote.id,
                      onSelect: () => setState(() => selectedQuoteId = quote.id),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                // Actions
                Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
                   child: Row(
                      children: [
                         ElevatedButton(
                           onPressed: () {}, // Approve Logic
                           style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                           child: const Text('Approve Selected Quote'),
                         ),
                         const SizedBox(width: 16),
                         OutlinedButton(
                           onPressed: () {},
                           style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                           child: const Text('Request More Quotes'),
                         ),
                      ],
                   ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  DataRow _buildRow(String label, List<Bid> quotes, dynamic Function(Bid) valueBuilder, {bool isDiscount = false}) {
    return DataRow(cells: [
      DataCell(Text(label, style: TextStyle(color: Colors.grey[600]))),
      ...quotes.map((q) {
        final val = valueBuilder(q);
        if (val is Widget) return DataCell(val);
        return DataCell(Text(val.toString(), style: TextStyle(
          color: isDiscount ? Colors.green : Colors.black,
          fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal
        )));
      }),
    ]);
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _QuickStat(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final Bid quote;
  final bool isSelected;
  final VoidCallback onSelect;

  const _ColumnHeader({required this.quote, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (quote.isRecommended == true) ...[
               Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                 Icon(Icons.verified, size: 14, color: isSelected ? Colors.white : Colors.amber), 
                 const SizedBox(width: 4), 
                 Text('Recommended', style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.amber))
               ]),
               const SizedBox(height: 8),
            ],
            Text(quote.vendorName ?? 'Vendor', style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
               const Icon(Icons.star, size: 14, color: Colors.amber), 
               Text('${quote.vendorRating ?? 0}', style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12))
            ]),
          ],
        ),
      ),
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final bool isgood;
  const _HighlightText(this.text, {required this.isgood});
  @override 
  Widget build(BuildContext context) {
    return Row(children: [
      Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isgood ? Colors.green : Colors.black)),
      if (isgood) ...[const SizedBox(width: 4), const Icon(Icons.check, size: 16, color: Colors.green)]
    ]);
  }
}

class _RatingCell extends StatelessWidget {
  final double rating;
  final bool isBest;
  const _RatingCell(this.rating, {required this.isBest});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
       const Icon(Icons.star, size: 16, color: Colors.amber),
       const SizedBox(width: 4),
       Text('$rating', style: TextStyle(color: isBest ? Colors.green : Colors.black, fontWeight: isBest ? FontWeight.bold : FontWeight.normal)),
    ]);
  }
}

class _DetailedQuoteCard extends StatelessWidget {
  final Bid quote;
  final bool isSelected;
  final VoidCallback onSelect;
  const _DetailedQuoteCard({required this.quote, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? Colors.amber : Colors.grey[200]!, width: isSelected ? 2 : 1),
        boxShadow: isSelected ? [BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 10)] : AppTheme.cardDecoration.boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(quote.vendorName ?? 'Vendor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (quote.advantages != null && quote.advantages!.isNotEmpty) ...[
            Text('Advantages', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 8),
            ...quote.advantages!.take(4).map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [const Icon(Icons.check, size: 14, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(a.toString(), style: const TextStyle(fontSize: 13)))]),
            )),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: isSelected 
                ? ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white)
                : OutlinedButton.styleFrom(foregroundColor: Colors.black),
              child: Text(isSelected ? 'Selected' : 'Select Quote'),
            ),
          )
        ],
      ),
    );
  }
}
