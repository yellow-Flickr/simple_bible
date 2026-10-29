import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// A titled, bordered card of rows separated by dividers, as used on the
/// Profile and About screens.
class SettingsSection extends StatelessWidget {
  const SettingsSection(
      {super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                for (final (index, child) in children.indexed) ...[
                  if (index > 0) Divider(height: 1, color: theme.dividerColor),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
