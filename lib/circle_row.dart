import 'package:flutter/material.dart';

class CircleRow extends StatelessWidget {
  final List<Color> circleColors = [
    Colors.white,
    Colors.grey,
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  final ValueChanged<Color> onColorSelected;
  final Color selectedColor;

  CircleRow({required this.onColorSelected, required this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: circleColors.map((color) {
        bool isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () {
            onColorSelected(color);
          },
          child: CircleAvatar(
            radius: 12,
            backgroundColor: color,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 16,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
