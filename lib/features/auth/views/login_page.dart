import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pasar_lokal_mvvm/core/models/demo_account.dart';
import 'package:pasar_lokal_mvvm/features/auth/viewmodels/auth_view_model.dart';
import 'package:pasar_lokal_mvvm/features/auth/views/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'andi@example.com');
  final _passwordController = TextEditingController(text: 'rahasia123');
  bool _obscurePassword = true;

  void _showNotAvailableSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur belum tersedia untuk demo ini.')),
    );
  }

  Future<void> _signInWithAccount(DemoAccount account) async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isLoading) {
      return;
    }

    _emailController.text = account.email;
    _passwordController.text = account.password;
    authViewModel.clearError();
    await _submit();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authViewModel = context.read<AuthViewModel>();
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final success = await authViewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (!success && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage!)));
    }
  }

  Future<void> _submitGoogle() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isLoading) return;

    final success = await authViewModel.loginWithGoogle();
    if (!mounted) return;

    if (!success && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outline),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.onPrimary.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: scheme.onPrimary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PasarLokal',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Selamat Datang!',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: scheme.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Masuk untuk melanjutkan belanja.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onPrimary.withValues(
                                      alpha: 0.92,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email', style: theme.textTheme.bodySmall),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'nama@contoh.com',
                                  prefixIcon: const Icon(Icons.mail_outline),
                                  border: inputBorder,
                                  enabledBorder: inputBorder,
                                  focusedBorder: inputBorder.copyWith(
                                    borderSide: BorderSide(
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),
                                onChanged: (_) => authViewModel.clearError(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email tidak boleh kosong.';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Pastikan email sudah benar.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Kata sandi',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Minimal 6 karakter',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                  border: inputBorder,
                                  enabledBorder: inputBorder,
                                  focusedBorder: inputBorder.copyWith(
                                    borderSide: BorderSide(
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),
                                onChanged: (_) => authViewModel.clearError(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kata sandi wajib diisi.';
                                  }
                                  if (value.length < 6) {
                                    return 'Minimal 6 karakter ya.';
                                  }
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showNotAvailableSnackBar,
                                  child: const Text('Lupa Password?'),
                                ),
                              ),
                              if (authViewModel.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    authViewModel.errorMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed:
                                      authViewModel.isLoading ? null : _submit,
                                  child:
                                      authViewModel.isLoading
                                          ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: scheme.onPrimary,
                                            ),
                                          )
                                          : const Text('Masuk'),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: scheme.outline),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'ATAU',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: scheme.outline,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: scheme.outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      authViewModel.isLoading
                                          ? null
                                          : _submitGoogle,
                                  icon: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: scheme.surfaceContainerHighest,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'G',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  label: const Text('Masuk dengan Google'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                children: [
                                  Text(
                                    'Belum punya akun?',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.outline,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: const Text('Daftar Sekarang'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (authViewModel.demoAccounts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _DemoAccountPanel(
                        accounts: authViewModel.demoAccounts,
                        onSelect:
                            authViewModel.isLoading ? null : _signInWithAccount,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoAccountPanel extends StatelessWidget {
  const _DemoAccountPanel({required this.accounts, required this.onSelect});

  final List<DemoAccount> accounts;
  final Future<void> Function(DemoAccount)? onSelect;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun demo tersedia',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...accounts.map(
              (account) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DemoAccountTile(account: account, onSelect: onSelect),
              ),
            ),
            Text(
              'Pilih akun untuk mengisi otomatis email dan kata sandi.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  const _DemoAccountTile({required this.account, required this.onSelect});

  final DemoAccount account;
  final Future<void> Function(DemoAccount)? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final roleLabel = account.isSeller ? 'Penjual' : 'Pembeli';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Text(
          account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
          style: TextStyle(color: scheme.onPrimaryContainer),
        ),
      ),
      title: Text(
        '${account.name} • $roleLabel',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text('${account.email}\nPassword: ${account.password}'),
      isThreeLine: true,
      trailing: TextButton(
        onPressed:
            onSelect == null ? null : () async => onSelect!.call(account),
        child: const Text('Gunakan'),
      ),
    );
  }
}
