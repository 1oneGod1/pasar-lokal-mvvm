import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/payment_method.dart';
import '../viewmodels/payment_methods_view_model.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  Future<void> _openForm({PaymentMethod? existing}) async {
    final result = await showModalBottomSheet<PaymentMethod>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return _PaymentMethodForm(existing: existing);
      },
    );

    if (!mounted || result == null) return;

    final viewModel = context.read<PaymentMethodsViewModel>();
    if (existing == null) {
      viewModel.addMethod(result);
    } else {
      viewModel.updateMethod(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final viewModel = context.watch<PaymentMethodsViewModel>();
    final methods = viewModel.methods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode pembayaran'),
        actions: [
          IconButton(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah metode',
          ),
        ],
      ),
      body:
          methods.isEmpty
              ? _EmptyState(onAdd: () => _openForm())
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final method = methods[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          _iconForType(method.type),
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(method.label),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${method.type.label} • ${method.maskedNumber}'),
                          if (method.isDefault)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Metode utama',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton<_MethodAction>(
                        onSelected: (action) {
                          switch (action) {
                            case _MethodAction.setDefault:
                              viewModel.setDefault(method.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Metode utama diperbarui.'),
                                ),
                              );
                              break;
                            case _MethodAction.edit:
                              _openForm(existing: method);
                              break;
                            case _MethodAction.delete:
                              viewModel.deleteMethod(method.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Metode dihapus.'),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: _MethodAction.setDefault,
                                child: Text('Jadikan utama'),
                              ),
                              const PopupMenuItem(
                                value: _MethodAction.edit,
                                child: Text('Ubah'),
                              ),
                              const PopupMenuItem(
                                value: _MethodAction.delete,
                                child: Text('Hapus'),
                              ),
                            ],
                      ),
                      isThreeLine: method.isDefault,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                      subtitleTextStyle: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      dense: false,
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  IconData _iconForType(PaymentMethodType type) {
    return switch (type) {
      PaymentMethodType.bank => Icons.account_balance_outlined,
      PaymentMethodType.ewallet => Icons.account_balance_wallet_outlined,
      PaymentMethodType.card => Icons.credit_card_outlined,
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.credit_card_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              'Belum ada metode pembayaran.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan rekening atau e-wallet untuk pembayaran lebih cepat.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Tambah metode'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodForm extends StatefulWidget {
  const _PaymentMethodForm({this.existing});

  final PaymentMethod? existing;

  @override
  State<_PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<_PaymentMethodForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  PaymentMethodType _selectedType = PaymentMethodType.bank;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _selectedType = existing?.type ?? PaymentMethodType.bank;
    _isDefault = existing?.isDefault ?? false;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _nameController = TextEditingController(text: existing?.accountName ?? '');
    _numberController = TextEditingController(
      text: existing?.accountNumber ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final existing = widget.existing;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    existing == null
                        ? 'Tambah metode'
                        : 'Ubah metode pembayaran',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethodType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis metode',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items:
                  PaymentMethodType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Nama bank / e-wallet',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama metode tidak boleh kosong.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama pemilik',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama pemilik tidak boleh kosong.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nomor rekening / e-wallet',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor tidak boleh kosong.';
                }
                if (value.trim().length < 6) {
                  return 'Nomor terlalu pendek.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
              title: const Text('Jadikan metode utama'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) return;

                  final method = PaymentMethod(
                    id:
                        existing?.id ??
                        'pm-${DateTime.now().millisecondsSinceEpoch}',
                    type: _selectedType,
                    label: _labelController.text.trim(),
                    accountName: _nameController.text.trim(),
                    accountNumber: _numberController.text.trim(),
                    isDefault: _isDefault,
                  );

                  Navigator.of(context).pop(method);
                },
                child: Text(existing == null ? 'Simpan' : 'Perbarui'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MethodAction { setDefault, edit, delete }
