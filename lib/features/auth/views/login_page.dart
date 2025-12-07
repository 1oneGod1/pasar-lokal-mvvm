import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pasar_lokal_mvvm/core/models/demo_account.dart';
import 'package:pasar_lokal_mvvm/features/auth/viewmodels/auth_view_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Consumer<AuthViewModel>(
                builder: (context, authViewModel, child) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang kembali!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masuk untuk melanjutkan belanja di Pasar Lokal.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        Text('Email', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'nama@contoh.com',
                            prefixIcon: Icon(Icons.mail_outline),
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
                        const SizedBox(height: 20),
                        Text('Kata sandi', style: theme.textTheme.bodySmall),
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
                        const SizedBox(height: 12),
                        if (authViewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              authViewModel.errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: authViewModel.isLoading ? null : _submit,
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
                                    : const Text('Masuk'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _DemoAccountPanel(
                          accounts: authViewModel.demoAccounts,
                          onSelect:
                              authViewModel.isLoading
                                  ? null
                                  : _signInWithAccount,
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Tips keamanan: jangan bagikan kata sandi Anda ke orang lain.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
    final roleLabel = account.isSeller ? 'Penjual' : 'Pembeli';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.black,
        child: Text(
          account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
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
