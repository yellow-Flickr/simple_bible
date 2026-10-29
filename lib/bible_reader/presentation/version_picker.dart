import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/user_space/application/user_space_service.dart';

/// Lets the user pick the app-wide Bible version from the installed ones.
void showVersionPicker(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final versions = ref.read(scriptureServiceProvider).getVersions();
  final selectedId = ref.read(preferredVersionIdProvider);

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ListView.builder(
      shrinkWrap: true,
      itemCount: versions.length,
      itemBuilder: (context, index) {
        final version = versions[index];
        final selected = version.id == selectedId;
        return ListTile(
          onTap: () {
            ref
                .read(userSpaceProvider.notifier)
                .setPreferredTranslation(version.id);
            Navigator.pop(context);
          },
          title: Text(
            version.versionName,
            style: theme.textTheme.bodyMedium!
                .copyWith(color: theme.primaryColorLight),
          ),
          trailing:
              selected ? Icon(Icons.check, color: theme.primaryColorDark) : null,
        );
      },
    ),
  );
}
