import 'package:simple_bible/topics/domain/topic.dart';

class Reflection {
  const Reflection({
    required this.id,
    required this.topicSlug,
    required this.title,
    required this.reference,
    required this.reflection,
    required this.question,
    required this.action,
    required this.prayer,
  });

  final String id;
  final String topicSlug;
  final String title;

  /// The passage the reflection is about, in canonical numbering.
  final TopicReference reference;
  final String reflection;
  final String question;
  final String action;
  final String prayer;
}

/// A reflection as it was shown on a given day.
typedef ReflectionEntry = ({DateTime date, Reflection reflection});
