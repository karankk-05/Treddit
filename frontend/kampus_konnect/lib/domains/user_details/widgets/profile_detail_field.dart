import 'package:flutter/material.dart';

class Profile_detail_field extends StatelessWidget {
  const Profile_detail_field({
    super.key,
    required this.context,
    required this.title,
    required this.detail,
    required this.icon,
  });

  final BuildContext context;
  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.onSurface.withOpacity(0.5),
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
