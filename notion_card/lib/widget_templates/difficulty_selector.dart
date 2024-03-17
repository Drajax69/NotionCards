import 'package:flutter/material.dart';

// DTO for selector button
class SelectorButton {
  final String title;
  final Color color;
  final double width;

  SelectorButton({
    required this.title,
    required this.color,
    required this.width,
  });
}

class DifficultySelector extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<SelectorButton> selectorButtons;

  const DifficultySelector({
    super.key,
    required this.index,
    required this.onChanged,
    required this.selectorButtons,
  });

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  int _selectedIndex = -1;

  @override
  initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.selectorButtons.length,
        (i) => _buildSelectorButton(
          i + 1,
          widget.selectorButtons[i],
          context,
        ),
      ),
    );
  }

  Widget _buildSelectorButton(
      int value, SelectorButton button, BuildContext context) {
    final bool isSelected = _selectedIndex == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = value;
        });
        widget.onChanged(value);
      },
      child: Container(
        width: button.width,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? button.color
              : const Color.fromARGB(255, 234, 230, 230),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            button.title,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
