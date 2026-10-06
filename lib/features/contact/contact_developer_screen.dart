import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

class ContactDeveloperScreen extends StatelessWidget {
  const ContactDeveloperScreen({super.key});

  static const String _company = 'ARKTECH SOLUTIONS';

  static const List<String> _phones = <String>[
    '+2348134839763',
    '+2348050344913',
  ];

  static const List<String> _emails = <String>[
    'info@arktechsolution.top',
    'emotiondevelopershub@gmail.com',
  ];

  Future<void> _launch(
    BuildContext context,
    Uri uri, {
    required String failureMessage,
  }) async {
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(failureMessage),
          ),
        );
    }
  }

  Future<void> _call(
    BuildContext context,
    String phone,
  ) async {
    await _launch(
      context,
      Uri(
        scheme: 'tel',
        path: phone,
      ),
      failureMessage:
          'Unable to open the phone dialer.',
    );
  }

  Future<void> _whatsApp(
    BuildContext context,
    String phone,
  ) async {
    final String digits =
        phone.replaceAll(RegExp(r'[^0-9]'), '');

    final Uri uri = Uri.parse(
      'https://wa.me/$digits'
      '?text=${Uri.encodeComponent('Hello Arktech Solutions, I am contacting you from the Arktech Calculator app.')}',
    );

    await _launch(
      context,
      uri,
      failureMessage:
          'Unable to open WhatsApp.',
    );
  }

  Future<void> _email(
    BuildContext context,
    String email,
  ) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: const <String, String>{
        'subject':
            'Arktech Calculator Enquiry',
      },
    );

    await _launch(
      context,
      uri,
      failureMessage:
          'Unable to open your email application.',
    );
  }

  Future<void> _copy(
    BuildContext context,
    String value,
    String label,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: value),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label copied'),
          duration:
              const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Contact Developer'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 860,
            ),
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                30,
              ),
              children: <Widget>[
                _buildHero(context),
                const SizedBox(height: 18),
                const Text(
                  'Get in touch',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'For support, product enquiries, partnerships or development services, contact Arktech Solutions through any of the channels below.',
                  style: TextStyle(
                    color:
                        AppTheme.secondaryText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                _ContactSection(
                  icon:
                      Icons.phone_in_talk_outlined,
                  iconBackground:
                      const Color(0xFF0F766E),
                  title: 'Phone & WhatsApp',
                  subtitle:
                      'Call directly or start a WhatsApp conversation.',
                  children: _phones
                      .map(
                        (String phone) =>
                            _PhoneContactCard(
                          phone: phone,
                          onCall: () =>
                              _call(
                            context,
                            phone,
                          ),
                          onWhatsApp: () =>
                              _whatsApp(
                            context,
                            phone,
                          ),
                          onCopy: () =>
                              _copy(
                            context,
                            phone,
                            'Phone number',
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                _ContactSection(
                  icon:
                      Icons.alternate_email,
                  iconBackground:
                      const Color(0xFF7C3AED),
                  title: 'Email',
                  subtitle:
                      'Send a detailed enquiry or support request.',
                  children: _emails
                      .map(
                        (String email) =>
                            _EmailContactCard(
                          email: email,
                          onEmail: () =>
                              _email(
                            context,
                            email,
                          ),
                          onCopy: () =>
                              _copy(
                            context,
                            email,
                            'Email address',
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                _buildTrustCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF7C3AED),
            Color(0xFF2563EB),
            Color(0xFF0891B2),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2563EB)
                .withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                alignment:
                    Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.16),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(0.28),
                  ),
                ),
                child: const Text(
                  'AS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: <Widget>[
                    Text(
                      _company,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing:
                            0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Technology • Software • Digital Solutions',
                      style: TextStyle(
                        color:
                            Color(0xFFE0F2FE),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Developer of Arktech Calculator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We build practical digital products designed to solve real problems, improve learning and support modern businesses.',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.verified_outlined,
            color: Color(0xFF22C55E),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Official developer contact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Use the contact details on this page for official Arktech Solutions support and enquiries.',
                  style: TextStyle(
                    color:
                        AppTheme.secondaryText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection
    extends StatelessWidget {
  const _ContactSection({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                alignment:
                    Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme
                            .secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PhoneContactCard
    extends StatelessWidget {
  const _PhoneContactCard({
    required this.phone,
    required this.onCall,
    required this.onWhatsApp,
    required this.onCopy,
  });

  final String phone;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.numberKey,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF475569),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          SelectableText(
            phone,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 0.25,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: onCall,
                icon: const Icon(
                  Icons.call_outlined,
                ),
                label:
                    const Text('Call'),
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2563EB,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onWhatsApp,
                icon: const Icon(
                  Icons.chat_outlined,
                ),
                label: const Text(
                  'WhatsApp',
                ),
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF16A34A,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(
                  Icons.copy_outlined,
                ),
                label:
                    const Text('Copy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmailContactCard
    extends StatelessWidget {
  const _EmailContactCard({
    required this.email,
    required this.onEmail,
    required this.onCopy,
  });

  final String email;
  final VoidCallback onEmail;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.numberKey,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF475569),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          SelectableText(
            email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: onEmail,
                icon: const Icon(
                  Icons.email_outlined,
                ),
                label: const Text(
                  'Send email',
                ),
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF7C3AED,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(
                  Icons.copy_outlined,
                ),
                label:
                    const Text('Copy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
