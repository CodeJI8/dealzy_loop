import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for Clipboard
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DealzyloopUserAgreementPage extends StatelessWidget {
  const DealzyloopUserAgreementPage({super.key});

  static const String _email = 'support@dealzyloop.com';
  static const String _title = 'Dealzyloop Shop App – End User License Agreement (EULA) & Terms of Service';
  static const String _lastUpdated = 'Last updated: September 24, 2025';
  static const String _version = 'v1.0';

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _email));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email address copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW =
            constraints.maxWidth > 720 ? 720.0 : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(_lastUpdated,
                                style: text.bodySmall?.copyWith(color: theme.hintColor)),
                            Text('  •  ',
                                style: text.bodySmall?.copyWith(color: theme.hintColor)),
                            Text(_version,
                                style: text.bodySmall?.copyWith(color: theme.hintColor)),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Divider(height: 1, thickness: 1),
                        SizedBox(height: 16.h),

                        _sectionTitle(context, '1. Acceptance of Terms'),
                        _para(context,
                            'By creating an account or using the Dealzyloop Shop app, you agree to be bound by these Terms of Service. If you do not agree, you may not use the app.'),

                        _sectionTitle(context, '2. No Tolerance for Objectionable Content or Abusive Conduct'),
                        _para(context,
                            'Dealzyloop has zero tolerance for objectionable content, abusive behavior, harassment, or illegal activity. Examples include:'),
                        _bullet('- Offensive, hateful, or discriminatory language or images'),
                        _bullet('- Fraudulent, misleading, or false deals or listings'),
                        _bullet('- Spam or repeated posting of irrelevant content'),
                        _bullet('- Harassing, threatening, or abusive interactions with customers'),

                        _sectionTitle(context, '3. Content Moderation'),
                        _bullet('- Shops must only post lawful, respectful, and accurate deals.'),
                        _bullet('- Dealzyloop reserves the right to remove any content that violates these terms without notice.'),
                        _bullet('- Shops that repeatedly violate these rules may have their accounts suspended or permanently banned.'),

                        _sectionTitle(context, '4. Reporting & Blocking'),
                        _bullet('- Users can report objectionable content directly in the app.'),
                        _bullet('- Users may block or mute shops they find abusive.'),
                        _bullet('- Reports are reviewed within 24 hours. Content violating these Terms will be removed, and offending shops may be banned.'),

                        _sectionTitle(context, '5. Your Responsibilities'),
                        _bullet('- Shops are responsible for the accuracy and legality of their listings.'),
                        _bullet('- Shops must not misuse the platform to post misleading or harmful content.'),

                        _sectionTitle(context, '6. Limitation of Liability'),
                        _para(context,
                            'Dealzyloop provides the platform “as is” and is not liable for user-generated content.'),

                        _sectionTitle(context, '7. Changes to Terms'),
                        _para(context,
                            'We may update these Terms from time to time. Continued use of the app means you accept the updated Terms.'),

                        SizedBox(height: 24.h),
                        Divider(height: 1, thickness: 1),
                        SizedBox(height: 12.h),
                        Center(child: _tiny(context, 'Contact: $_email')),
                        SizedBox(height: 12.h),
                        Center(
                          child: FilledButton.icon(
                            onPressed: () => _copyEmail(context),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Email'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _para(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _tiny(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).hintColor));
  }
}
