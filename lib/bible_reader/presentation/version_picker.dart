import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/user_space/application/user_space_service.dart';

/// Lets the user pick a Bible version from the installed ones.
///
/// [selectedId] is ticked (defaults to the app-wide version) and [onSelected]
/// is called with the choice (defaults to setting the app-wide version).
void showVersionPicker(
  BuildContext context,
  WidgetRef ref, {
  int? selectedId,
  ValueChanged<int>? onSelected,
}) {
  final theme = Theme.of(context);
  final versions = ref.read(scriptureServiceProvider).getVersions();
  final current = selectedId ?? ref.read(preferredVersionIdProvider);

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
        return ListTile(
          onTap: () {
            if (onSelected != null) {
              onSelected(version.id);
            } else {
              ref
                  .read(userSpaceProvider.notifier)
                  .setPreferredTranslation(version.id);
            }
            Navigator.pop(context);
          },
          title: Text(
            version.versionName,
            style: theme.textTheme.bodyMedium!
                .copyWith(color: theme.primaryColorLight),
          ),
          trailing: version.id == current
              ? Icon(Icons.check, color: theme.primaryColorDark)
              : null,
        );
      },
    ),
  );
}

/// App bar action showing the current version's short name; tapping it opens
/// [showVersionPicker].
class VersionButton extends ConsumerWidget {
  const VersionButton({
    super.key,
    required this.label,
    this.selectedId,
    this.onSelected,
  });

  /// Short version name, such as `KJV`.
  final String? label;
  final int? selectedId;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: () => showVersionPicker(
        context,
        ref,
        selectedId: selectedId,
        onSelected: onSelected,
      ),
      icon: Icon(Icons.translate, size: 16, color: theme.primaryColorDark),
      label: Text(
        label ?? '',
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
