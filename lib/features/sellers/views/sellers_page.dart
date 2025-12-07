import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/seller.dart';
import '../viewmodels/seller_view_model.dart';

class SellersPage extends StatelessWidget {
  const SellersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SellerViewModel>();
    final sellers = viewModel.sellers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _openSellerForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Seller'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                sellers.isEmpty
                    ? const Center(child: Text('No sellers yet.'))
                    : ListView.separated(
                      itemCount: sellers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final seller = sellers[index];
                        return Card(
                          child: ListTile(
                            title: Text(seller.name),
                            subtitle: Text(
                              '${seller.location} • Rating ${seller.rating.toStringAsFixed(1)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit seller',
                                  onPressed:
                                      () => _openSellerForm(
                                        context,
                                        seller: seller,
                                      ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Delete seller',
                                  onPressed:
                                      () => _confirmDelete(context, seller),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSellerForm(BuildContext context, {Seller? seller}) async {
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<SellerViewModel>();

    final nameController = TextEditingController(text: seller?.name ?? '');
    final locationController = TextEditingController(
      text: seller?.location ?? '',
    );
    final ratingController = TextEditingController(
      text: seller != null ? seller.rating.toStringAsFixed(1) : '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(seller == null ? 'Add Seller' : 'Edit Seller'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Seller name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rating (0-5)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final location = locationController.text.trim();
                final ratingValue = double.tryParse(
                  ratingController.text.trim() == ''
                      ? '0'
                      : ratingController.text.trim(),
                );

                if (name.isEmpty || location.isEmpty || ratingValue == null) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('All seller fields are required.'),
                    ),
                  );
                  return;
                }

                final sanitizedRating = ratingValue.clamp(0, 5).toDouble();

                final updatedSeller = Seller(
                  id:
                      seller?.id ??
                      'seller-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  location: location,
                  rating: sanitizedRating,
                );

                if (seller == null) {
                  viewModel.addSeller(updatedSeller);
                  messenger.showSnackBar(
                    SnackBar(content: Text('${updatedSeller.name} added.')),
                  );
                } else {
                  viewModel.updateSeller(updatedSeller);
                  messenger.showSnackBar(
                    SnackBar(content: Text('${updatedSeller.name} updated.')),
                  );
                }

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    locationController.dispose();
    ratingController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Seller seller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Seller'),
          content: Text('Delete ${seller.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      context.read<SellerViewModel>().deleteSeller(seller.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${seller.name} deleted.')));
    }
  }
}
