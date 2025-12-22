import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/category.dart';
import '../viewmodels/category_view_model.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoryViewModel>();
    final categories = viewModel.categories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _openCategoryForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                categories.isEmpty
                    ? const Center(child: Text('No categories yet.'))
                    : ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Card(
                          child: ListTile(
                            title: Text(category.name),
                            subtitle:
                                category.description.isEmpty
                                    ? null
                                    : Text(category.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit category',
                                  onPressed:
                                      () => _openCategoryForm(
                                        context,
                                        category: category,
                                      ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Delete category',
                                  onPressed:
                                      () => _confirmDelete(context, category),
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

  Future<void> _openCategoryForm(
    BuildContext context, {
    Category? category,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<CategoryViewModel>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
                if (name.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Category name is required.')),
                  );
                  return;
                }

                final updatedCategory = Category(
                  id:
                      category?.id ??
                      'cat-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  description: descriptionController.text.trim(),
                );

                if (category == null) {
                  viewModel.addCategory(updatedCategory);
                  messenger.showSnackBar(
                    SnackBar(content: Text('${updatedCategory.name} added.')),
                  );
                } else {
                  viewModel.updateCategory(updatedCategory);
                  messenger.showSnackBar(
                    SnackBar(content: Text('${updatedCategory.name} updated.')),
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

    if (!context.mounted) {
      nameController.dispose();
      descriptionController.dispose();
      return;
    }

    nameController.dispose();
    descriptionController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text('Delete ${category.name}?'),
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

    if (!context.mounted) {
      return;
    }

    if (confirmed == true) {
      context.read<CategoryViewModel>().deleteCategory(category.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${category.name} deleted.')));
    }
  }
}
