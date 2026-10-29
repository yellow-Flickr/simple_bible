import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/user_space/legal_content.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.title, required this.sections});

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 4.h),
        children: [
          Text(
            'Effective $legalEffectiveDate',
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
          ),
          for (final section in sections) ...[
            SizedBox(height: 2.5.h),
            Text(
              section.heading,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            SizedBox(height: .5.h),
            Text(
              section.body,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
