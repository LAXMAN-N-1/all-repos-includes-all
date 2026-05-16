import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_support.dart';
import 'package:google_fonts/google_fonts.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Knowledge Base", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Manage help articles and documentation for tenants.", style: TextStyle(color: Colors.white60)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: (){}, 
                icon: const Icon(Icons.add), 
                label: const Text("New Article")
              )
            ],
          ),
          const SizedBox(height: 32),
          
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search articles by title, tag, or content...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AuraColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AuraColors.glassBorder)),
            ),
          ),
          const SizedBox(height: 24),

          // Categories Chips
          Row(
            children: [
              _buildCategoryChip("All", true),
              _buildCategoryChip("Billing", false),
              _buildCategoryChip("Technical", false),
              _buildCategoryChip("Inventory", false),
              _buildCategoryChip("Admin", false),
            ],
          ),
          const SizedBox(height: 24),
          
          // Articles List
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: mockKBArticles.length,
              itemBuilder: (context, index) {
                final article = mockKBArticles[index];
                return Card(
                  color: AuraColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AuraColors.glassBorder)),
                  child: InkWell(
                    onTap: (){},
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AuraColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(article.category.toUpperCase(), style: const TextStyle(color: AuraColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              const Icon(Icons.edit_note, color: Colors.white30, size: 18),
                            ],
                          ),
                          const Spacer(),
                          Text(article.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.visibility, size: 14, color: Colors.white30),
                              const SizedBox(width: 4),
                              Text("${article.views} views", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                              const Spacer(),
                              Text("Updated ${article.lastUpdated}", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (b){},
        selectedColor: AuraColors.primary,
        backgroundColor: AuraColors.surface,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : AuraColors.glassBorder)),
      ),
    );
  }
}
