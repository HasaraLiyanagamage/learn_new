import 'package:flutter/material.dart';

class QuizOptionButton extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback? onTap;
  final int optionIndex;

  const QuizOptionButton({
    super.key,
    required this.option,
    required this.isSelected,
    this.isCorrect,
    this.onTap,
    required this.optionIndex,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (isCorrect != null) {
      // Show result
      if (isCorrect!) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      // Selected but not submitted
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
      borderColor = Theme.of(context).primaryColor;
      icon = Icons.radio_button_checked;
    } else {
      // Not selected
      icon = Icons.radio_button_unchecked;
      borderColor = Colors.grey.shade300;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor ?? Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isCorrect != null
                          ? (isCorrect! ? Colors.green : Colors.red)
                          : Theme.of(context).primaryColor)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + optionIndex), // A, B, C, D
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Option text
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              
              // Status icon
              if (icon != null)
                Icon(
                  icon,
                  color: isCorrect != null
                      ? (isCorrect! ? Colors.green : (isSelected ? Colors.red : Colors.grey))
                      : (isSelected ? Theme.of(context).primaryColor : Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
