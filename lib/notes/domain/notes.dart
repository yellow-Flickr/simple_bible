import 'package:objectbox/objectbox.dart';

@Entity()
class Notes {
  @Id()
  int? uid;
  @Unique(onConflict: ConflictStrategy.replace)
  final String id;
  final String createdAt;
  final String lastModified;
  final String title;
  final String content;
  // final List<Quotation> reference;

  Notes({
    required this.id,
    required this.createdAt,
    required this.lastModified,
    required this.title,
    required this.content,
    // required this.reference,
  });

  Notes copywith({
    int? uid,
    String? id,
    String? createdAt,
    String? lastModified,
    String? title,
    String? content,
    // List<Quotation>? reference,
  }) {
    final note = Notes(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      title: title ?? this.title,
      content: content ?? this.content,
      // reference: reference ?? this.reference
    );

    note.uid = uid ?? this.uid;
    return note;
  }
}
