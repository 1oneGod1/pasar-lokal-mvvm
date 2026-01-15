import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Kami siap membantu Anda.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cari jawaban cepat di bawah atau hubungi tim support kami.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'FAQ',
            children: const [
              _FaqTile(
                question: 'Bagaimana cara mengganti profil?',
                answer:
                    'Masuk ke menu Akun → Pengaturan → Ubah profil untuk memperbarui data Anda.',
              ),
              _FaqTile(
                question: 'Bagaimana menambahkan metode pembayaran?',
                answer:
                    'Masuk ke menu Akun → Pengaturan → Metode pembayaran, lalu tekan Tambah.',
              ),
              _FaqTile(
                question: 'Pesanan saya tidak muncul?',
                answer:
                    'Pastikan Anda sudah checkout. Coba refresh di tab Pesanan.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Hubungi kami',
            children: const [
              _ContactTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'support@pasarlokal.id',
              ),
              _ContactTile(
                icon: Icons.phone_outlined,
                title: 'Telepon',
                subtitle: '+62 811 0000 1111',
              ),
              _ContactTile(
                icon: Icons.chat_bubble_outline,
                title: 'WhatsApp',
                subtitle: '+62 812 3456 7890',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Jam layanan',
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.access_time_outlined),
                title: Text('Senin - Jumat'),
                subtitle: Text('08.00 - 18.00 WIB'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.access_time_outlined),
                title: Text('Sabtu - Minggu'),
                subtitle: Text('09.00 - 15.00 WIB'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(question),
      children: [Align(alignment: Alignment.centerLeft, child: Text(answer))],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
