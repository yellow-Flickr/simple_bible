# Reflection writing prompt

**To use as is:** copy everything between the two `=====` lines and paste it into an LLM. It already contains style samples and 10 starter topics with their passages.

**For other topics:** run `build_reflection_prompt.py` (needs only Python 3). It finds this template and your data files near where you run it, and asks for a path if it can't find one.

    python3 build_reflection_prompt.py                      # this prompt, unchanged
    python3 build_reflection_prompt.py --topics love,prayer # your own topics
    python3 build_reflection_prompt.py --count 10           # the 10 topics with the fewest reflections

Each run picks different candidate passages. It prints the seed so a run can be repeated with `--seed`.

=====
You are helping write daily devotional reflections for an offline Bible app. Each reflection is tied to one topic and one Bible passage. People read it in about a minute.

## Your task
For each topic below, write exactly 3 NEW reflections. Each must be built on a different passage chosen ONLY from that topic's candidate passages. Output a single JSON array and nothing else.

## Output format
Each element has exactly these fields:

{
  "id": "<slug>-<NNN>",
  "topic": "<slug>",
  "title": "<2-5 words>",
  "book": "<copy exactly from the candidate>",
  "chapter": <number, copied>,
  "verses": "<copied, e.g. \"16\" or \"20-23\">",
  "reflection": "<2-4 sentences>",
  "question": "<one sentence>",
  "action": "<one sentence>",
  "prayer": "<one or two sentences, ending with Amen.>"
}

- `id` continues the numbering given as `next_id` for that topic (increase by one for each extra reflection).
- `book`, `chapter` and `verses` must be copied exactly from a candidate. Do not invent, merge or change passages. A passage that is not in the candidate list will be rejected.
- Do not put the verse text in any field. The app shows the verse separately.
- Inside strings use single quotes ('like this'), never double quotes. Output valid JSON.

## Writing rules
1. **Be faithful to the verse.** Read the KJV text given and say only what the verse and its immediate context support. Do not claim anything about Hebrew or Greek, history or context unless you are certain. If unsure, leave it out.
2. **Do not promise outcomes.** Never imply that faith, prayer or giving guarantees healing, wealth, success or the removal of hardship. Say what God is like and what He invites us to do.
3. **No shame, no pressure.** Speak with warmth and honesty. Do not guilt the reader. On sensitive topics (sexuality, addiction, suffering, death, sickness, hell, punishment, marriage, poverty, persecution, depression) be especially gentle, never graphic, and point toward grace and toward trusted people or professional help where appropriate.
4. **No denominational arguments.** Stay with mainstream Christian teaching. Avoid contested doctrines (end-times timelines, church order, baptism mode, speaking in tongues, predestination).
5. **Plain English** at about a Grade 7 reading level. Short sentences. No jargon, no churchy cliches (for example 'in this season', 'unpack', 'journey', 'lean in').
6. **reflection:** 2-4 sentences. Explain the verse in everyday terms and connect it to ordinary life. Do not just repeat the verse.
7. **question:** one sentence, personal and honest, that the reader can answer in their own head. Not yes/no. Not rhetorical.
8. **action:** one small, concrete thing a person can do TODAY in about ten minutes or less, at no cost. Avoid vague actions such as 'reflect on' or 'be kind'.
9. **prayer:** first person, simple, speaks directly to God, and ends with 'Amen.'
10. **Vary the shape.** Do not begin every reflection the same way. Do not reuse the phrases or ideas from the samples or from the 'already written' lists.
11. **title:** 2-5 words, specific to this passage, not just the topic name. Titles must be unique.
12. **Keep batches small.** Write at most 3 reflections per topic and at most 10 topics per response. If you are given more than 10 topics, write only the first 10 and ignore the rest. Quality matters more than quantity; long outputs make reflections generic.
13. **Vary the passages.** Across a response, use a different passage for every reflection, and spread your choices across the candidate list instead of always taking the first ones.

## Before you answer, check each item
- The passage is exactly one of the candidates.
- Nothing is claimed that the verse does not support.
- No promise of an outcome. No shame.
- Question, action and prayer follow the rules above.
- No more than 3 reflections per topic and 10 topics in total.
- The JSON is valid and contains only the array.

## Style samples (match this voice and length; do not copy them)
[
  {
    "id": "faith-001",
    "topic": "faith",
    "title": "Trusting Beyond Sight",
    "book": "Hebrews",
    "chapter": 11,
    "verses": "1",
    "reflection": "Faith is not pretending to know how everything will turn out. It is resting on what God has promised while the outcome is still out of view. The things we hope for are real to God before they are visible to us.",
    "question": "Where are you waiting to see before you will trust?",
    "action": "Name one situation you cannot control and hand it to God in a short prayer.",
    "prayer": "Lord, help me trust You in what I cannot yet see. Amen."
  },
  {
    "id": "fear-001",
    "topic": "fear",
    "title": "Whom Shall I Fear?",
    "book": "Psalm",
    "chapter": 27,
    "verses": "1",
    "reflection": "David asks two questions with obvious answers: whom shall I fear, and of whom shall I be afraid? He does not say there is nothing frightening, but that the Lord is his light, his salvation and the strength of his life.",
    "question": "What would change if you answered these two questions out loud?",
    "action": "Say the verse aloud when fear shows up today.",
    "prayer": "Lord, You are my light and my salvation. Be the strength of my life. Amen."
  },
  {
    "id": "contentment-001",
    "topic": "contentment",
    "title": "Learning to Be Content",
    "book": "Philippians",
    "chapter": 4,
    "verses": "11",
    "reflection": "Paul says he has learned to be content in whatever state he is in, which means contentment is learned, not natural. He wrote this from prison. Contentment does not depend on our circumstances but on where we find our security.",
    "question": "What do you believe you need before you can be content?",
    "action": "Thank God for three ordinary things you already have.",
    "prayer": "Lord, teach me to be content in every circumstance. Amen."
  },
  {
    "id": "calling-001",
    "topic": "calling",
    "title": "Called to Bless",
    "book": "1 Peter",
    "chapter": 3,
    "verses": "9",
    "reflection": "Peter says we are called to answer evil with blessing, and that blessing is something we inherit. A calling is not only a job or a title; it is how we respond when we are wronged.",
    "question": "Is there someone you could bless instead of answering back?",
    "action": "Say something kind about, or pray for, someone who has been difficult.",
    "prayer": "Lord, help me answer unkindness with blessing, as I have been blessed. Amen."
  }
]

## Topics and candidate passages
<!-- TOPICS:START -->
### Love  (slug: love)
related topics: neighbor, law, god, jesus, faith, reliability
next_id: love-002
already written (do not repeat these ideas or titles):
  - "As I Have Loved You" (John 13:34)
candidate passages (KJV), pick 3:
  - book="1 Corinthians" chapter=13 verses="1"  |  Though I speak with the tongues of men and of angels, and have not charity, I am become as sounding brass, or a tinkling cymbal.
  - book="Galatians" chapter=5 verses="6"  |  For in Jesus Christ neither circumcision availeth anything, nor uncircumcision; but faith which worketh by love.
  - book="Psalm" chapter=143 verses="8"  |  Cause me to hear thy lovingkindness in the morning; for in thee do I trust: cause me to know the way wherein I should walk; for I lift up my soul unto thee.
  - book="John" chapter=15 verses="10"  |  If ye keep my commandments, ye shall abide in my love; even as I have kept my Father's commandments, and abide in his love.
  - book="Joel" chapter=2 verses="13"  |  And rend your heart, and not your garments, and turn unto the LORD your God: for he is gracious and merciful, slow to anger, and of great kindness, and repenteth him of the evil.
  - book="Psalm" chapter=94 verses="18"  |  When I said, My foot slippeth; thy mercy, O LORD, held me up.

### Joy  (slug: joy)
related topics: life, heart, food, god, law, sadness
next_id: joy-002
already written (do not repeat these ideas or titles):
  - "Joy That Remains" (John 15:11)
candidate passages (KJV), pick 3:
  - book="Romans" chapter=12 verses="15"  |  Rejoice with them that do rejoice, and weep with them that weep.
  - book="Matthew" chapter=17 verses="5"  |  While he yet spake, behold, a bright cloud overshadowed them: and behold a voice out of the cloud, which said, This is my beloved Son, in whom I am well pleased; hear ye him.
  - book="1 Timothy" chapter=6 verses="6"  |  But godliness with contentment is great gain.
  - book="Romans" chapter=15 verses="32"  |  That I may come unto you with joy by the will of God, and may with you be refreshed.
  - book="Romans" chapter=5 verses="3-4"  |  And not only so, but we glory in tribulations also: knowing that tribulation worketh patience; And patience, experience; and experience, hope:
  - book="John" chapter=16 verses="24"  |  Hitherto have ye asked nothing in my name: ask, and ye shall receive, that your joy may be full.

### Gratitude  (slug: gratitude)
related topics: worship, prayer, jesus, peace, creation, speaking
next_id: gratitude-002
already written (do not repeat these ideas or titles):
  - "Peace and Thankfulness" (Colossians 3:15)
candidate passages (KJV), pick 3:
  - book="Philippians" chapter=4 verses="6-7"  |  Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God. And the peace of God, which passeth all understanding, shall keep your hearts and minds through Christ Jesus.
  - book="Colossians" chapter=3 verses="17"  |  And whatsoever ye do in word or deed, do all in the name of the Lord Jesus, giving thanks to God and the Father by him.
  - book="Psalm" chapter=9 verses="1"  |  I will praise thee, O LORD, with my whole heart; I will shew forth all thy marvellous works.
  - book="1 Chronicles" chapter=16 verses="34"  |  O give thanks unto the LORD; for he is good; for his mercy endureth for ever.
  - book="Psalm" chapter=50 verses="23"  |  Whoso offereth praise glorifieth me: and to him that ordereth his conversation aright will I shew the salvation of God.
  - book="2 Corinthians" chapter=9 verses="11"  |  Being enriched in every thing to all bountifulness, which causeth through us thanksgiving to God.

### Trust  (slug: trust)
related topics: faith, fear, safety, protection, heart, blessing
next_id: trust-002
already written (do not repeat these ideas or titles):
  - "Trust and Do Good" (Psalm 37:3)
candidate passages (KJV), pick 3:
  - book="Nahum" chapter=1 verses="7"  |  The LORD is good, a strong hold in the day of trouble; and he knoweth them that trust in him.
  - book="Proverbs" chapter=3 verses="31-32"  |  Envy thou not the oppressor, and choose none of his ways. For the froward is abomination to the LORD: but his secret is with the righteous.
  - book="Psalm" chapter=31 verses="19"  |  Oh how great is thy goodness, which thou hast laid up for them that fear thee; which thou hast wrought for them that trust in thee before the sons of men!
  - book="John" chapter=14 verses="1"  |  Let not your heart be troubled: ye believe in God, believe also in me.
  - book="Matthew" chapter=6 verses="26"  |  Behold the fowls of the air: for they sow not, neither do they reap, nor gather into barns; yet your heavenly Father feedeth them. Are ye not much better than they?
  - book="Psalm" chapter=91 verses="1-2"  |  He that dwelleth in the secret place of the most High shall abide under the shadow of the Almighty. I will say of the LORD, He is my refuge and my fortress: my God; in him will I trust.

### Patience  (slug: patience)
related topics: love, end-times, grace, righteousness, compassion, anger
next_id: patience-002
already written (do not repeat these ideas or titles):
  - "Rest and Wait" (Psalm 37:7)
candidate passages (KJV), pick 3:
  - book="2 Peter" chapter=3 verses="9"  |  The Lord is not slack concerning his promise, as some men count slackness; but is longsuffering to us-ward, not willing that any should perish, but that all should come to repentance.
  - book="Psalm" chapter=5 verses="3"  |  My voice shalt thou hear in the morning, O LORD; in the morning will I direct my prayer unto thee, and will look up.
  - book="Hebrews" chapter=10 verses="36"  |  For ye have need of patience, that, after ye have done the will of God, ye might receive the promise.
  - book="Matthew" chapter=24 verses="42"  |  Watch therefore: for ye know not what hour your Lord doth come.
  - book="Romans" chapter=8 verses="25"  |  But if we hope for that we see not, then do we with patience wait for it.
  - book="Matthew" chapter=24 verses="13"  |  But he that shall endure unto the end, the same shall be saved.

### Praise  (slug: praise)
related topics: worship, speaking, singing, soul, prayer, blessing
next_id: praise-002
already written (do not repeat these ideas or titles):
  - "I Will Extol You" (Psalm 145:1)
candidate passages (KJV), pick 3:
  - book="Isaiah" chapter=12 verses="4"  |  And in that day shall ye say, Praise the LORD, call upon his name, declare his doings among the people, make mention that his name is exalted.
  - book="Psalm" chapter=63 verses="3-4"  |  Because thy lovingkindness is better than life, my lips shall praise thee. Thus will I bless thee while I live: I will lift up my hands in thy name.
  - book="Psalm" chapter=119 verses="7"  |  I will praise thee with uprightness of heart, when I shall have learned thy righteous judgments.
  - book="Isaiah" chapter=25 verses="1"  |  O LORD, thou art my God; I will exalt thee, I will praise thy name; for thou hast done wonderful things; thy counsels of old are faithfulness and truth.
  - book="Psalm" chapter=108 verses="3"  |  I will praise thee, O LORD, among the people: and I will sing praises unto thee among the nations.
  - book="Psalm" chapter=28 verses="7"  |  The LORD is my strength and my shield; my heart trusted in him, and I am helped: therefore my heart greatly rejoiceth; and with my song will I praise him.

### Wisdom  (slug: wisdom)
related topics: understanding, mind, speaking, life, the-word, anger
next_id: wisdom-002
already written (do not repeat these ideas or titles):
  - "Walk with the Wise" (Proverbs 13:20)
candidate passages (KJV), pick 3:
  - book="Proverbs" chapter=18 verses="2"  |  A fool hath no delight in understanding, but that his heart may discover itself.
  - book="Ecclesiastes" chapter=1 verses="18"  |  For in much wisdom is much grief: and he that increaseth knowledge increaseth sorrow.
  - book="Proverbs" chapter=15 verses="5"  |  A fool despiseth his father's instruction: but he that regardeth reproof is prudent.
  - book="Romans" chapter=11 verses="33"  |  O the depth of the riches both of the wisdom and knowledge of God! how unsearchable are his judgments, and his ways past finding out!
  - book="Proverbs" chapter=17 verses="7"  |  Excellent speech becometh not a fool: much less do lying lips a prince.
  - book="Proverbs" chapter=8 verses="35"  |  For whoso findeth me findeth life, and shall obtain favour of the LORD.

### Generosity  (slug: generosity)
related topics: giving, food, receiving, harvest, selfishness, joy
next_id: generosity-002
already written (do not repeat these ideas or titles):
  - "A Cheerful Giver" (2 Corinthians 9:7)
candidate passages (KJV), pick 3:
  - book="Luke" chapter=6 verses="38"  |  Give, and it shall be given unto you; good measure, pressed down, and shaken together, and running over, shall men give into your bosom. For with the same measure that ye mete withal it shall be measured to you again.
  - book="2 Corinthians" chapter=8 verses="12"  |  For if there be first a willing mind, it is accepted according to that a man hath, and not according to that he hath not.
  - book="James" chapter=1 verses="5"  |  If any of you lack wisdom, let him ask of God, that giveth to all men liberally, and upbraideth not; and it shall be given him.
  - book="2 Corinthians" chapter=9 verses="10"  |  Now he that ministereth seed to the sower both minister bread for your food, and multiply your seed sown, and increase the fruits of your righteousness;)
  - book="2 Corinthians" chapter=9 verses="11"  |  Being enriched in every thing to all bountifulness, which causeth through us thanksgiving to God.
  - book="Isaiah" chapter=40 verses="29"  |  He giveth power to the faint; and to them that have no might he increaseth strength.

### Peace  (slug: peace)
related topics: blessing, life, love, righteousness, jesus, evil
next_id: peace-003
already written (do not repeat these ideas or titles):
  - "Safe to Sleep" (Psalm 4:8)
  - "Not as the World Gives" (John 14:27)
candidate passages (KJV), pick 3:
  - book="Colossians" chapter=3 verses="15"  |  And let the peace of God rule in your hearts, to the which also ye are called in one body; and be ye thankful.
  - book="Psalm" chapter=29 verses="11"  |  The LORD will give strength unto his people; the LORD will bless his people with peace.
  - book="John" chapter=16 verses="33"  |  These things I have spoken unto you, that in me ye might have peace. In the world ye shall have tribulation: but be of good cheer; I have overcome the world.
  - book="Acts" chapter=9 verses="31"  |  Then had the churches rest throughout all Judaea and Galilee and Samaria, and were edified; and walking in the fear of the Lord, and in the comfort of the Holy Ghost, were multiplied.
  - book="John" chapter=20 verses="21"  |  Then said Jesus to them again, Peace be unto you: as my Father hath sent me, even so send I you.
  - book="Proverbs" chapter=12 verses="20"  |  Deceit is in the heart of them that imagine evil: but to the counsellers of peace is joy.

### Hope  (slug: hope)
related topics: encouragement, spirit, promises, soul, faith, truth
next_id: hope-003
already written (do not repeat these ideas or titles):
  - "A Living Hope" (1 Peter 1:3)
  - "The God of Hope" (Romans 15:13)
candidate passages (KJV), pick 3:
  - book="1 Corinthians" chapter=13 verses="13"  |  And now abideth faith, hope, charity, these three; but the greatest of these is charity.
  - book="Romans" chapter=8 verses="25"  |  But if we hope for that we see not, then do we with patience wait for it.
  - book="Psalm" chapter=25 verses="5"  |  Lead me in thy truth, and teach me: for thou art the God of my salvation; on thee do I wait all the day.
  - book="1 Corinthians" chapter=13 verses="6-7"  |  Rejoiceth not in iniquity, but rejoiceth in the truth; Beareth all things, believeth all things, hopeth all things, endureth all things.
  - book="Psalm" chapter=119 verses="114"  |  Thou art my hiding place and my shield: I hope in thy word.
  - book="Lamentations" chapter=3 verses="24"  |  The LORD is my portion, saith my soul; therefore will I hope in him.
<!-- TOPICS:END -->
=====

## After the LLM answers
1. Save the array to a file and check that it is valid JSON.
2. Append its entries to the end of the `reflections` list in your reflections JSON. If the app shows them in file order, new ones belong at the end.
3. Validate: every id is unique, every topic exists, no field is empty, and each passage is one of that topic's passages. If your project has a test for this, run it.
4. Read every new reflection yourself before release. Validation checks structure, not theology or tone.
