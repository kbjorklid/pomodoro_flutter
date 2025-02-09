import 'package:flutter/material.dart';

/// Reusable ListTile widget for settings screen.
///
/// Can be configured with a title, optional subtitle, and a trailing widget.
class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? below;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
      this.trailing,
      this.below});

  @override
  Widget build(BuildContext context) {
    return below == null
        ? _buildListTile(context)
        : _buildListTileAndBelowWidget(context);
  }

  Widget _buildListTile(BuildContext context) {
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

  Widget _buildListTileAndBelowWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListTile(context),
        below!,
      ],
    );
  }
}
