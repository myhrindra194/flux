import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Une erreur est survenue : $error')),
        data: (products) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                onTap: () {
                  context.push('/products/${product.id}');
                },
                leading: Image.network(
                  product.thumbnail,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
                title: Text(product.title),
                subtitle: Text('${product.price.toStringAsFixed(2)} \$'),
                trailing: Text('⭐ ${product.rating.toStringAsFixed(1)}'),
              );
            },
          );
        },
      ),
    );
  }
}
