import 'package:coka/models/chip_data.dart';
import 'package:flutter/material.dart';

import 'chip_input.dart';

class CustomChipInput extends StatefulWidget {
  final List<ChipData> itemsMenu;
  final Function(List<ChipData>) onItemChange;
  final List<ChipData> itemInitValue;
  final String hintText;
  final FocusNode? focusNode;
  final bool? showArrowDown;
  const CustomChipInput({
    super.key,
    required this.itemInitValue,
    required this.onItemChange,
    required this.itemsMenu,
    required this.hintText,
    this.focusNode,
    this.showArrowDown,
  });

  @override
  State<CustomChipInput> createState() => _CustomChipInputState();
}

class _CustomChipInputState extends State<CustomChipInput> {
  final categoryChipKey = GlobalKey<ChipsInputState>();

  @override
  Widget build(BuildContext context) {
    return ChipsInput(
      focusNode: widget.focusNode,
      initialSuggestions: widget.itemsMenu,
      initialValue: widget.itemInitValue,
      key: categoryChipKey,
      keyboardAppearance: Brightness.dark,
      textCapitalization: TextCapitalization.words,
      textStyle: const TextStyle(height: 1.5, fontSize: 16),
      allowChipEditing: true,
      suggestionsBoxMaxHeight: 400,
      decoration: InputDecoration(
          hintText: widget.hintText,
          suffixIcon: (widget.showArrowDown ?? false)
              ? const Icon(Icons.keyboard_arrow_down)
              : null,
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none)),
      findSuggestions: (String query) {
        if (query.isNotEmpty) {
          var lowercaseQuery = query.toLowerCase();
          return widget.itemsMenu.where((profile) {
            return profile.name.toLowerCase().contains(query.toLowerCase()) ||
                profile.id.toLowerCase().contains(query.toLowerCase());
          }).toList(growable: false)
            ..sort((a, b) => a.name
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.name.toLowerCase().indexOf(lowercaseQuery)));
        }
        // return <AppProfile>[];
        return widget.itemsMenu;
      },
      onChanged: widget.onItemChange,
      chipBuilder: (context, state, dynamic profile) {
        return InputChip(
          key: ObjectKey(profile),
          label: Text(profile.name),
          onDeleted: () => state.deleteChip(profile),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, dynamic profile) {
        return ListTile(
          key: ObjectKey(profile),
          title: Text(profile.name),
          onTap: () => state.selectSuggestion(profile),
        );
      },
    );
  }
}
