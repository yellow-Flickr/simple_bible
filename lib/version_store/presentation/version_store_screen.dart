import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show installedVersionsProvider;
import 'package:simple_bible/shared/network_providers.dart';
import 'package:simple_bible/shared/widgets/settings_section.dart';
import 'package:simple_bible/version_store/application/version_store_controller.dart';
import 'package:simple_bible/version_store/domain/catalogue.dart';
import 'package:simple_bible/version_store/domain/download_job.dart';

/// Lists the versions in the catalogue, grouped by language, with download,
/// update and remove actions.
class VersionStoreScreen extends ConsumerStatefulWidget {
  const VersionStoreScreen({super.key});

  static const routeName = '/versions';

  static Route<void> route() => MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => const VersionStoreScreen(),
      );

  @override
  ConsumerState<VersionStoreScreen> createState() => _VersionStoreScreenState();
}

class _VersionStoreScreenState extends ConsumerState<VersionStoreScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogue = ref.watch(catalogueProvider);
    final jobs = ref.watch(versionDownloadControllerProvider);
    final online = ref.watch(isOnlineProvider);

    // Swap the saved list for a fresh one once the connection is back.
    ref.listen(isOnlineProvider, (wasOnline, online) {
      final fromCache = ref.read(catalogueProvider).valueOrNull?.fromCache;
      if (online && wasOnline == false && (fromCache ?? true)) _refresh();
    });

    final banner = _bannerMessage(
      online: online,
      fromCache: catalogue.valueOrNull?.fromCache ?? false,
      waiting: jobs.values.any((job) => job.waitingForNetwork),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bible versions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: banner == null
                ? const SizedBox(width: double.infinity)
                : _NetworkBanner(
                    message: banner,
                    offline: !online,
                    onRetry: online ? _refresh : null,
                  ),
          ),
          Expanded(
            child: catalogue.when(
              data: (snapshot) => RefreshIndicator(
                onRefresh: _refresh,
                child: _list(snapshot.catalogue, jobs),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(onRetry: _refresh),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() => ref.read(catalogueProvider.notifier).refresh();

  String? _bannerMessage({
    required bool online,
    required bool fromCache,
    required bool waiting,
  }) {
    if (waiting) return 'Downloads paused — waiting for connection';
    if (!online) return "You're offline — showing the last saved list";
    if (fromCache) {
      return "Couldn't refresh the list — showing the last saved one";
    }
    return null;
  }

  Widget _list(Catalogue catalogue, Map<String, DownloadJob> jobs) {
    final revisions = ref.watch(installedRevisionsProvider);
    final canRemove = ref.watch(installedVersionsProvider).length > 1;
    final filter = _filter.trim().toLowerCase();
    final entries = catalogue.entries
        .where((entry) =>
            filter.isEmpty ||
            '${entry.name} ${entry.abbreviation} ${entry.languageName}'
                .toLowerCase()
                .contains(filter))
        .toList()
      ..sort((a, b) {
        final byLanguage = a.languageName.compareTo(b.languageName);
        return byLanguage != 0 ? byLanguage : a.name.compareTo(b.name);
      });
    final languages = {for (final entry in entries) entry.languageName};

    return ListView(
      // Keep pull-to-refresh working when the list is short.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 4.h),
      children: [
        TextField(
          onChanged: (value) => setState(() => _filter = value),
          decoration: const InputDecoration(
            hintText: 'Search versions or languages',
            prefixIcon: Icon(Icons.search),
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: const Center(child: Text('No versions found')),
          ),
        for (final language in languages)
          SettingsSection(
            title: language,
            children: [
              for (final entry in entries)
                if (entry.languageName == language)
                  _VersionTile(
                    entry: entry,
                    job: jobs[entry.id],
                    availability: availabilityOf(entry, revisions[entry.id]),
                    canRemove: canRemove,
                  ),
            ],
          ),
      ],
    );
  }
}

class _VersionTile extends ConsumerWidget {
  const _VersionTile({
    required this.entry,
    required this.job,
    required this.availability,
    required this.canRemove,
  });

  final CatalogueEntry entry;
  final DownloadJob? job;
  final VersionAvailability availability;
  final bool canRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final error = job?.phase == DownloadPhase.failed ? job!.error : null;
    return ListTile(
      title: Text(entry.name),
      subtitle: Text(
        error ??
            [
              entry.abbreviation,
              formatBytes(entry.sizeBytes),
              if (entry.license != null) entry.license,
            ].join(' · '),
        style: error == null ? null : TextStyle(color: theme.colorScheme.error),
      ),
      trailing: _action(context, ref),
    );
  }

  Widget _action(BuildContext context, WidgetRef ref) {
    final controller = ref.read(versionDownloadControllerProvider.notifier);
    final job = this.job;
    if (job != null) {
      return switch (job.phase) {
        DownloadPhase.queued => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Queued'),
              IconButton(
                tooltip: 'Cancel',
                icon: const Icon(Icons.close),
                onPressed: () => controller.cancel(entry.id),
              ),
            ],
          ),
        DownloadPhase.downloading => SizedBox.square(
            dimension: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.square(
                  dimension: 30,
                  child: CircularProgressIndicator(
                    value: job.progress,
                    strokeWidth: 2.5,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                IconButton(
                  tooltip: 'Cancel',
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => controller.cancel(entry.id),
                ),
              ],
            ),
          ),
        DownloadPhase.installing => const Tooltip(
            message: 'Installing',
            child: SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        DownloadPhase.failed => IconButton(
            tooltip: 'Retry',
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.retry(entry.id),
          ),
      };
    }

    return switch (availability) {
      VersionAvailability.notInstalled => IconButton(
          tooltip: 'Download',
          icon: const Icon(Icons.download_outlined),
          onPressed: () => _download(context, ref),
        ),
      VersionAvailability.updateAvailable => TextButton(
          onPressed: () => _download(context, ref),
          child: const Text('Update'),
        ),
      VersionAvailability.installed => canRemove
          ? IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _remove(context, ref),
            )
          : Icon(Icons.check, color: Theme.of(context).primaryColorDark),
      VersionAvailability.unsupported => const Text('Update the app'),
    };
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    if (ref.read(isMeteredProvider)) {
      final confirmed = await _confirm(
        context,
        title: 'Use mobile data?',
        message: '${entry.name} is about ${formatBytes(entry.sizeBytes)}.',
        action: 'Download',
      );
      if (!confirmed) return;
    }
    ref.read(versionDownloadControllerProvider.notifier).download(entry);
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Remove ${entry.abbreviation}?',
      message: 'You can download ${entry.name} again later.',
      action: 'Remove',
    );
    if (confirmed) {
      ref.read(versionDownloadControllerProvider.notifier).remove(entry.id);
    }
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _NetworkBanner extends StatelessWidget {
  const _NetworkBanner({
    required this.message,
    required this.offline,
    required this.onRetry,
  });

  final String message;
  final bool offline;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 0),
      padding: EdgeInsets.only(left: 4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primaryColorDark),
      ),
      child: Row(
        children: [
          Icon(
            offline ? Icons.wifi_off : Icons.cloud_off_outlined,
            size: 20,
            color: theme.primaryColorDark,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            SizedBox(height: 2.h),
            const Text(
              "Couldn't load the list of versions. Check your connection and try again.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// `10.4 MB`, `850 KB`.
String formatBytes(int bytes) {
  if (bytes >= 1000 * 1000) {
    return '${(bytes / (1000 * 1000)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1000).ceil()} KB';
}
