import 'package:flutter/material.dart';

/// A robust searchable dropdown built over Flutter's Autocomplete.
/// Supports async searching (e.g. fetching from API) or local filtering.
class SearchableDropdown<T extends Object> extends StatelessWidget {
  final Future<Iterable<T>> Function(String) onSearch;
  final String Function(T) displayStringForOption;
  final void Function(T) onSelected;
  final String labelText;
  final String hintText;
  final Widget? prefixIcon;
  final T? initialValue;

  const SearchableDropdown({
    super.key,
    required this.onSearch,
    required this.displayStringForOption,
    required this.onSelected,
    this.labelText = 'Search',
    this.hintText = 'Type to search...',
    this.prefixIcon = const Icon(Icons.search),
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => Autocomplete<T>(
        initialValue: initialValue != null 
            ? TextEditingValue(text: displayStringForOption(initialValue as T))
            : TextEditingValue.empty,
        displayStringForOption: displayStringForOption,
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.isEmpty) return const Iterable.empty();
          return await onSearch(textEditingValue.text);
        },
        onSelected: onSelected,
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            onFieldSubmitted: (String value) => onFieldSubmitted(),
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: focusNode.hasFocus
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        textEditingController.clear();
                        focusNode.unfocus();
                      },
                    )
                  : const Icon(Icons.arrow_drop_down),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 250,
                  maxWidth: constraints.maxWidth,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final T option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      title: Text(displayStringForOption(option)),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
