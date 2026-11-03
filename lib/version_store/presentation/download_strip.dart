import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';
import 'package:simple_bible/version_store/application/version_store_controller.dart';
import 'package:simple_bible/version_store/domain/download_job.dart';

/// A slim bar above the bottom navigation showing the running download, so
/// progress stays visible after leaving the versions screen.
class DownloadStrip extends ConsumerWidget {
  const DownloadStrip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final jobs = ref.watch(versionDownloadControllerProvider).values;
    final running = jobs
        .where((job) =>
            job.phase == DownloadPhase.downloading ||
            job.phase == DownloadPhase.installing)
        .firstOrNull;
    final queued =
        jobs.where((job) => job.phase == DownloadPhase.queued).length;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: running == null
          ? const SizedBox(width: double.infinity)
          : Material(
              color: theme.cardColor,
              child: InkWell(
                onTap: onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: running.phase == DownloadPhase.downloading
                          ? running.progress
                          : null,
                      minHeight: 2,
                      color: theme.primaryColorDark,
                      backgroundColor: theme.dividerColor,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      child: Row(
                        children: [
                          Icon(Icons.download_outlined,
                              size: 18, color: theme.primaryColorDark),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _label(running),
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (queued > 0)
                            Text('+$queued more',
                                style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  static String _label(DownloadJob job) {
    final name = job.entry.abbreviation;
    if (job.phase == DownloadPhase.installing) return 'Installing $name…';
    final progress = job.progress;
    return progress == null
        ? 'Downloading $name'
        : 'Downloading $name · ${(progress * 100).floor()}%';
  }
}

/// Shows a snack bar when a version finishes installing or fails.
void announceVersionDownloads(
  BuildContext context,
  WidgetRef ref,
  Map<String, DownloadJob>? previous,
  Map<String, DownloadJob> next,
) {
  final messenger = ScaffoldMessenger.of(context);
  for (final job in (previous ?? const {}).values) {
    // Installing can't be cancelled, so leaving that phase without a failure
    // means it succeeded.
    if (job.phase != DownloadPhase.installing ||
        next.containsKey(job.entry.id)) {
      continue;
    }
    messenger.showSnackBar(SnackBar(
      content: Text('${job.entry.name} is ready'),
      action: SnackBarAction(
        label: 'Use it',
        onPressed: () => ref
            .read(userSpaceProvider.notifier)
            .setPreferredTranslation(job.entry.id),
      ),
    ));
  }
  for (final job in next.values) {
    // Offline failures retry on their own and are shown on the versions screen.
    if (job.phase != DownloadPhase.failed ||
        job.waitingForNetwork ||
        previous?[job.entry.id]?.phase == DownloadPhase.failed) {
      continue;
    }
    messenger.showSnackBar(SnackBar(
      content:
          Text("Couldn't download ${job.entry.abbreviation}: ${job.error}"),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () => ref
            .read(versionDownloadControllerProvider.notifier)
            .retry(job.entry.id),
      ),
    ));
  }
}
