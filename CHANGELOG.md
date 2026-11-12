# Changelog

All notable changes to Simple Bible are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the app uses [Semantic Versioning](https://semver.org/). Each version
matches `version:` in `pubspec.yaml` (without the `+build` number).

**How to use this file:**
- Add every user-visible change under **Unreleased** as you make it.
- Use these groups: Added, Changed, Fixed, Removed, Security.
- At release time, rename **Unreleased** to the new version and date, then copy
  the user-facing highlights to `docs/site/changelog.md` (the in-app "What's
  new" page). See `docs/RELEASING.md`.

## [Unreleased]

## [1.0.0] - Unreleased

The first public release.

### Added
- **Reader:**
  - Chapter-by-chapter reading with animated chapter navigation.
  - Go to any reference.
  - Verse highlighting, and multi-verse selection to copy, favourite or note.
- **Bible versions:**
  - King James Version and Akuapem Twi are bundled.
  - A version library downloads more translations, with progress, retry and
    cancel.
  - One version is chosen app-wide and shared by the reader, topics and search.
- **Topics:**
  - More than 160 topics, each with its verses shown in your chosen version.
  - A random topic sample on Home.
- **Verse of the Day:** tied to the day's reflection.
- **Daily reflections:**
  - A reflection, question, step and prayer for each day.
  - A history you can filter by topic.
- **Search:**
  - Jump straight to a reference.
  - Word and exact-phrase search across verses, notes and topics.
  - Whole-word option, and filters for testament and book.
  - Recent searches.
- **Notes:** a note editor with undo and redo.
- **Favourites and reading history.**
- **Profile:**
  - Bible version and theme (system, light or dark).
  - Share, rate, feedback and support links.
- **About:**
  - Acknowledgements and translation credits.
  - The app licence and the open-source licences.
- Privacy policy, terms of use and licence pages, hosted on GitHub Pages.

### Changed
- Android package is now `com.codekraft.simple_bible`.
- The app no longer applies the Kotlin Gradle Plugin; `MainActivity` is now
  Java.
- Java target raised to 17. Android Gradle Plugin and Gradle upgraded.

### Security
- Release builds are signed with an upload key from `android/key.properties`,
  which is never committed.

[Unreleased]: https://github.com/yellow-Flickr/simple_bible/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yellow-Flickr/simple_bible/releases/tag/v1.0.0
