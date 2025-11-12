import 'package:objectbox/objectbox.dart';

import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

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
  final List<Quotation> reference;

  Notes({
    required this.id,
    required this.createdAt,
    required this.lastModified,
    required this.title,
    required this.content,
    required this.reference,
  });

  Notes copywith({
    int? uid,
    String? id,
    String? createdAt,
    String? lastModified,
    String? title,
    String? content,
    List<Quotation>? reference,
  }) {
    final note = Notes(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastModified: lastModified ?? this.lastModified,
        title: title ?? this.title,
        content: content ?? this.content,
        reference: reference ?? this.reference);

    note.uid = uid ?? this.uid;
    return note;
  }
}

final List<Notes> notesSamples = [
  Notes(
    id: '0',
    createdAt: "20120525T132700",
    lastModified: "20120525T132700",
    title: 'Sermon 5/25',
    content:
        'Tyrus weaved through the cobbled streets, battling against the mob of people as the chilly air burrowed into his lungs. The effort to break free from the masses left him drained, but he persevered. Stopping at the side of the road, he stole a glance behind him, spotting two figures closing in. He stuffed a stale piece of bread deeper into his tunic and resumed sprinting.',
    reference: [],
  ),
  Notes(
    id: '1',
    createdAt: "20120527T132700",
    lastModified: "20120527T132700",
    title: 'Sermon 5/27',
    content:
        'Tyrus weaved through the cobbled streets, battling against the mob of people as the chilly air burrowed into his lungs. The effort to break free from the masses left him drained, but he persevered. Stopping at the side of the road, he stole a glance behind him, spotting two figures closing in. He stuffed a stale piece of bread deeper into his tunic and resumed sprinting.',
    reference: [],
  ),
  Notes(
    id: '2',
    createdAt: "20120529T132700",
    lastModified: "20120529T132700",
    title: 'Sermon 5/29',
    content:
        'Tyrus weaved through the cobbled streets, battling against the mob of people as the chilly air burrowed into his lungs. The effort to break free from the masses left him drained, but he persevered. Stopping at the side of the road, he stole a glance behind him, spotting two figures closing in. He stuffed a stale piece of bread deeper into his tunic and resumed sprinting.',
    reference: [
      Quotation(
        bookId: 1,
        chapter: 1,
        verse: 1,
        text: "In the beginning, God created the heavens and the earth.",
        versionId: 100,
      ),
      Quotation(
        bookId: 1,
        chapter: 1,
        verse: 2,
        text:
            "Now the earth was formless and empty, darkness was over the surface of the deep.",
        versionId: 100,
      ),
      Quotation(
        bookId: 2,
        chapter: 3,
        verse: 16,
        text: "For God so loved the world that he gave his one and only Son.",
        versionId: 100,
      ),
    ],
  ),
];
