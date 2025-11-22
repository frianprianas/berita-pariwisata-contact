import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tentang Aplikasi'),
        ),
        body: _buildContent(context),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Tentang Aplikasi'),
      ),
      child: SafeArea(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App Logo & Name
        Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/logo_kp.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Koran Pariwisata',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Platform Pengetahuan Pariwisata',
              style: TextStyle(
                fontSize: 16,
                color: Platform.isIOS
                    ? CupertinoColors.secondaryLabel.resolveFrom(context)
                    : Colors.grey.shade600,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF11998E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Version 2.5.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF11998E),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Contact Info
        _buildContactSection(
          context: context,
          title: 'Kontak',
          icon: CupertinoIcons.phone_fill,
          color: const Color(0xFF667EEA),
          website: 'www.koran-pariwisata.com',
          contactName: 'Joni Setia Budi',
          phone: '085182828181',
        ),

        const SizedBox(height: 24),

        // Developer Info
        _buildSection(
          title: 'Developer',
          icon: CupertinoIcons.person_fill,
          color: const Color(0xFF11998E),
          items: [
            'Frian Prianas',
            'frianprianas@gmail.com',
          ],
        ),

        const SizedBox(height: 24),

        // Credits
        _buildSection(
          title: 'Teknologi',
          icon: CupertinoIcons.gear_alt_fill,
          color: const Color(0xFF764BA2),
          items: [
            'Flutter 3.9.2',
            'Dart ^3.9.2',
            'SQLite Database',
            'On-Device AI Processing',
            'Indonesian TTS Engine',
          ],
        ),

        const SizedBox(height: 32),

        // Action Buttons
        _buildActionButton(
          context: context,
          icon: CupertinoIcons.globe,
          label: 'Kunjungi Website',
          color: const Color(0xFF667EEA),
          onTap: () => _launchUrl('https://koran-pariwisata.com'),
        ),

        const SizedBox(height: 12),

        _buildActionButton(
          context: context,
          icon: CupertinoIcons.mail,
          label: 'Hubungi Developer',
          color: const Color(0xFF11998E),
          onTap: () => _launchUrl('mailto:frianprianas@gmail.com'),
        ),

        const SizedBox(height: 12),

        _buildActionButton(
          context: context,
          icon: CupertinoIcons.share,
          label: 'Bagikan Aplikasi',
          color: const Color(0xFF764BA2),
          onTap: () => _shareApp(context),
        ),

        const SizedBox(height: 32),

        // Legal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Platform.isIOS
                ? CupertinoColors.systemGrey6.resolveFrom(context)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Hak Cipta © 2025 Frian Prianas',
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Aplikasi ini dikembangkan dengan ❤️ di Indonesia\n'
                'untuk mendukung industri pariwisata',
                style: TextStyle(
                  fontSize: 11,
                  color: Platform.isIOS
                      ? CupertinoColors.secondaryLabel.resolveFrom(context)
                      : Colors.grey.shade600,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Native Features Badge
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                CupertinoIcons.checkmark_shield_fill,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                '100% Native App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bukan agregator konten biasa.\n'
                'Platform pembelajaran pariwisata lengkap dengan\n'
                'fitur native yang powerful.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String website,
    required String contactName,
    required String phone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kontak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Website
              GestureDetector(
                onTap: () => _launchUrl('https://$website'),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.globe,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      website,
                      style: TextStyle(
                        fontSize: 15,
                        color: color,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Contact Name
              Row(
                children: [
                  Icon(
                    CupertinoIcons.person_fill,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    contactName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Phone
              GestureDetector(
                onTap: () => _launchUrl('tel:$phone'),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.phone_fill,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 15,
                        color: color,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  decoration: TextDecoration.none,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareApp(BuildContext context) {
    // TODO: Implement share functionality
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Share App'),
        content: const Text('Fitur share akan tersedia setelah rilis di App Store/Play Store.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
