import 'package:simple_bible/user_space/app_info.dart';

typedef LegalSection = ({String heading, String body});

const legalEffectiveDate = '29 October 2026';

const privacyPolicy = <LegalSection>[
  (
    heading: 'Summary',
    body: '${AppInfo.name} works entirely on your device. It has no accounts, '
        'no analytics, no ads and no tracking, and it does not send your data '
        'anywhere.',
  ),
  (
    heading: 'What the app stores',
    body: 'To work, the app keeps the following on your device only:\n'
        '• your display name and when you started using the app\n'
        '• your preferred Bible version and theme\n'
        '• notes, favourite verses and reading history\n'
        '• reflections you have been shown and your recent searches\n\n'
        'None of this leaves your device. We cannot see it.',
  ),
  (
    heading: 'Internet access',
    body: 'The Bible texts, topics and reflections are built into the app, so '
        'it does not need an internet connection. If you tap Rate & review, '
        'Send feedback, or Share, the app hands over to another app (the Play '
        'Store, your email app or the share sheet), and that app\'s own '
        'privacy policy applies.',
  ),
  (
    heading: 'Feedback',
    body: 'If you email us, we receive your email address and whatever you '
        'write. We use it only to reply and to improve the app, and we do not '
        'share it.',
  ),
  (
    heading: 'Deleting your data',
    body: 'Clearing the app\'s storage or uninstalling the app permanently '
        'deletes everything listed above.',
  ),
  (
    heading: 'Children',
    body: 'The app collects no personal information from anyone, including '
        'children.',
  ),
  (
    heading: 'Changes',
    body: 'If this policy changes, the new version will ship with an app '
        'update and the date above will change.',
  ),
  (
    heading: 'Contact',
    body: 'Questions? Email ${AppInfo.feedbackEmail}.',
  ),
];

const termsOfUse = <LegalSection>[
  (
    heading: 'Using the app',
    body: '${AppInfo.name} is free for personal, non-commercial use. By using '
        'it you agree to these terms.',
  ),
  (
    heading: 'Bible texts',
    body: 'The King James Version is in the public domain. Other translations '
        'remain the property of their copyright holders and are included for '
        'personal reading only. Do not copy them out of the app for '
        'redistribution or commercial use.',
  ),
  (
    heading: 'Reflections',
    body: 'Daily reflections are devotional writing meant to encourage. They '
        'are not pastoral, medical, legal or professional advice. If you are '
        'struggling, please talk to someone you trust or a qualified '
        'professional.',
  ),
  (
    heading: 'Your content',
    body: 'Your notes belong to you and stay on your device. You are '
        'responsible for backing up anything you want to keep.',
  ),
  (
    heading: 'No warranty',
    body: 'The app is provided "as is". We work to keep it accurate, but we '
        'cannot promise it is free of errors, and we are not liable for any '
        'loss arising from its use, as far as the law allows.',
  ),
  (
    heading: 'Changes',
    body: 'We may update these terms with a new version of the app. '
        'Continuing to use the app means you accept the updated terms.',
  ),
  (
    heading: 'Contact',
    body: 'Questions? Email ${AppInfo.feedbackEmail}.',
  ),
];
