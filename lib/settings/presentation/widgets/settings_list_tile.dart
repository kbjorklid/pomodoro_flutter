import 'package:flutter/material.dart';

/// Reusable ListTile widget for settings screen.
///
/// Can be configured with a title, optional subtitle, and a trailing widget.
class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget trailing;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            )
          : null,
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}
