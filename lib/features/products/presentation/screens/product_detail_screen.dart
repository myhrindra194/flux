import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Produit')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
        data: (product) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    product.thumbnail,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.image_not_supported, size: 100);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(product.category, style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 16),

                Text(
                  '${product.price.toStringAsFixed(2)} \$',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '⭐ ${product.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 24),

                Text(
                  product.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
