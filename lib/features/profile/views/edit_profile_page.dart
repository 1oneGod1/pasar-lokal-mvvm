import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/viewmodels/auth_view_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authViewModel = context.read<AuthViewModel>();
    if (_formKey.currentState?.validate() != true) return;

    final success = await authViewModel.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
      Navigator.of(context).pop();
      return;
    }

    final msg =
        authViewModel.errorMessage ?? 'Gagal memperbarui profil. Coba lagi.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final authViewModel = context.watch<AuthViewModel>();

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outline),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ubah profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Perbarui informasi akun Anda.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nama lengkap',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.mail_outline),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'No. HP',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor HP tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    textInputAction: TextInputAction.newline,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alamat tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: authViewModel.isLoading ? null : _submit,
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
                              : const Text('Simpan perubahan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
