import 'package:flutter/material.dart';

class Action_Buttons extends StatelessWidget {
  const Action_Buttons({
    super.key,
    required this.context,
    required this.label,
    required this.onTap,
  });

  final BuildContext context;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: theme.secondaryContainer,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: theme.onSecondaryContainer,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
