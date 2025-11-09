// import 'dart:convert';

import 'package:simple_bible/favorites/domain/favorite.dart';
import 'package:simple_bible/objectbox.g.dart';
import 'package:uuid/uuid.dart';

@Entity()
class UserSpace {
  @Id()
  int? uid;

  // Core Identification
  @Unique(onConflict: ConflictStrategy.replace)
  final String userId;
  final String? email;
  final String? username;
  final String? passwordHash;
  final String? authProvider;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  // Profile
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  // final String? location;
  // final String? preferredLanguage;

  // Settings / Preferences
  final int? theme; // "light", "dark", or "system"
  final int? fontSize;
  final int preferredTranslation; // "NIV", "KJV", etc.
  // final bool notificationsEnabled;
  // final String? dailyReminderTime; // e.g. "07:00"
  // final bool offlineMode;
  // final String? readingPlanId;

  // Spiritual / Activity
  final int streakDays;
  final int versesHighlighted;
  final int bookmarksCount;
  final int notesCount;
  // final String? lastReadReference;
  final List<Favorite> favoriteVerses;
  final List<String> readingHistory;
  final List<String> notes;
  // final int devotionalsCompleted;

  // Misc / System
  final String? appVersion;
  final String? deviceType; // "iOS", "Android", "Web"
  // final bool isPremium;
  // final String? subscriptionId;
  // final DateTime? deletedAt;

  UserSpace({
    required this.userId,
    this.email,
    this.username,
    this.passwordHash,
    this.authProvider,
    this.createdAt,
    this.lastLogin,
    this.fullName,
    this.avatarUrl,
    this.bio,
    // this.location,
    // this.preferredLanguage,
    this.theme,
    this.fontSize,
    this.preferredTranslation = 100,
    // this.notificationsEnabled = true,
    // this.dailyReminderTime,
    // this.offlineMode = false,
    // this.readingPlanId,
    this.streakDays = 0,
    this.versesHighlighted = 0,
    this.bookmarksCount = 0,
    this.notesCount = 0,
    // this.lastReadReference,
    this.favoriteVerses = const [],
    this.readingHistory = const [],
    this.notes = const [],
    // this.devotionalsCompleted = 0,
    this.appVersion,
    this.deviceType,
    // this.isPremium = false,
    // this.subscriptionId,
    // this.deletedAt,
  });

  factory UserSpace.guest() {
    final uuid = const Uuid().v4();
    return UserSpace(
      userId: 'guest-$uuid',
      username: 'Guest',
      authProvider: 'guest',
      createdAt: DateTime.now(),
      // notificationsEnabled: false,
      // offlineMode: true,
      preferredTranslation: 100,
      theme: 0,
      fontSize: 16,
      favoriteVerses: const [],
      readingHistory: const [],
      notes: const [],
    );
  }
  // factory UserSpace.fromJson(Map<String, dynamic> json) {
  //   return UserSpace(
  //     userId: json['userId'],
  //     email: json['email'],
  //     username: json['username'],
  //     passwordHash: json['passwordHash'],
  //     authProvider: json['authProvider'],
  //     createdAt:
  //         json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  //     lastLogin:
  //         json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
  //     fullName: json['fullName'],
  //     avatarUrl: json['avatarUrl'],
  //     bio: json['bio'],
  //     // location: json['location'],
  //     // preferredLanguage: json['preferredLanguage'],
  //     theme: json['theme'],
  //     fontSize: json['fontSize'],
  //     preferredTranslation: json['preferredTranslation'],
  //     // notificationsEnabled: json['notificationsEnabled'] ?? true,
  //     // dailyReminderTime: json['dailyReminderTime'],
  //     // offlineMode: json['offlineMode'] ?? false,
  //     // readingPlanId: json['readingPlanId'],
  //     streakDays: json['streakDays'] ?? 0,
  //     versesHighlighted: json['versesHighlighted'] ?? 0,
  //     bookmarksCount: json['bookmarksCount'] ?? 0,
  //     notesCount: json['notesCount'] ?? 0,
  //     // lastReadReference: json['lastReadReference'],
  //     favoriteVerses: json['favoriteVerses'] != null
  //         ? List<String>.from(json['favoriteVerses'])
  //         : [],
  //     readingHistory: json['readingHistory'] != null
  //         ? List<String>.from(json['favoriteVerses'])
  //         : [],
  //     // devotionalsCompleted: json['devotionalsCompleted'] ?? 0,
  //     appVersion: json['appVersion'],
  //     deviceType: json['deviceType'],
  //     // isPremium: json['isPremium'] ?? false,
  //     // subscriptionId: json['subscriptionId'],
  //     // deletedAt:
  //     //     json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'userId': userId,
  //     'email': email,
  //     'username': username,
  //     'passwordHash': passwordHash,
  //     'authProvider': authProvider,
  //     'createdAt': createdAt?.toIso8601String(),
  //     'lastLogin': lastLogin?.toIso8601String(),
  //     'fullName': fullName,
  //     'avatarUrl': avatarUrl,
  //     'bio': bio,
  //     // 'location': location,
  //     // 'preferredLanguage': preferredLanguage,
  //     'theme': theme,
  //     'fontSize': fontSize,
  //     'preferredTranslation': preferredTranslation,
  //     // 'notificationsEnabled': notificationsEnabled,
  //     // 'dailyReminderTime': dailyReminderTime,
  //     // 'offlineMode': offlineMode,
  //     // 'readingPlanId': readingPlanId,
  //     'streakDays': streakDays,
  //     'versesHighlighted': versesHighlighted,
  //     'bookmarksCount': bookmarksCount,
  //     'notesCount': notesCount,
  //     // 'lastReadReference': lastReadReference,
  //     'favoriteVerses': favoriteVerses,
  //     'readingHistory': readingHistory,
  //     // 'devotionalsCompleted': devotionalsCompleted,
  //     'appVersion': appVersion,
  //     'deviceType': deviceType,
  //     // 'isPremium': isPremium,
  //     // 'subscriptionId': subscriptionId,
  //     // 'deletedAt': deletedAt?.toIso8601String(),
  //   };
  // }

  // String toJsonString() => jsonEncode(toJson());
  // factory UserSpace.fromJsonString(String source) =>
  //     UserSpace.fromJson(jsonDecode(source));
}
