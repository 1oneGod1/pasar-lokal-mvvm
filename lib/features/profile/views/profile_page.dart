import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pasar_lokal_mvvm/core/models/user.dart';
import 'package:pasar_lokal_mvvm/features/auth/viewmodels/auth_view_model.dart';
import 'package:pasar_lokal_mvvm/features/sellers/viewmodels/seller_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 56),
            const SizedBox(height: 12),
            Text(
              'Silakan masuk untuk melihat profil Anda.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final memberSinceText = 'Member sejak ${user.memberSince.year}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.black,
                child: Text(
                  initial,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(memberSinceText, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan Akun', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _ProfileRow(label: 'Alamat', value: user.address),
                  const SizedBox(height: 8),
                  _ProfileRow(label: 'No. HP', value: user.phone),
                  const SizedBox(height: 8),
                  _ProfileRow(label: 'Email', value: user.email),
                ],
              ),
            ),
          ),
          if (user.isSeller) ...[
            const SizedBox(height: 24),
            _StoreSummaryCard(user: user),
          ],
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengaturan', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _SettingsButton(label: 'Ubah profil', onTap: () {}),
                  _SettingsButton(label: 'Metode pembayaran', onTap: () {}),
                  _SettingsButton(label: 'Bantuan', onTap: () {}),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed:
                        authViewModel.isLoading ? null : authViewModel.logout,
                    child:
                        authViewModel.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Keluar akun'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _StoreSummaryCard extends StatelessWidget {
  const _StoreSummaryCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sellerViewModel = context.watch<SellerViewModel>();
    final store =
        user.sellerId != null ? sellerViewModel.findById(user.sellerId!) : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil Toko', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (store == null)
              Text(
                'Belum ada data toko terkait. Hubungi admin untuk menautkan toko.',
                style: theme.textTheme.bodySmall,
              )
            else ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      store.name.isNotEmpty ? store.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(store.location, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          store.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileRow(
                label: 'Status',
                value: 'Toko aktif dan menerima pesanan',
              ),
              const SizedBox(height: 8),
              _ProfileRow(label: 'ID Toko', value: store.id),
            ],
            if (store != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Lihat katalog'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Kelola toko'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
