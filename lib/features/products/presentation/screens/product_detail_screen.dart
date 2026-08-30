import 'package:api/core/errors/failures.dart';
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
        // =========================
        // LOADING
        // =========================
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        // =========================
        // ERROR
        // =========================
        error: (error, stackTrace) {
          final message = error is Failure
              ? error.message
              : 'Une erreur inattendue est survenue.';

          final icon = error is NetworkFailure
              ? Icons.wifi_off
              : error is ServerFailure
              ? Icons.cloud_off
              : error is CacheFailure
              ? Icons.storage
              : Icons.error_outline;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48),

                  const SizedBox(height: 16),

                  Text(message, textAlign: TextAlign.center),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(productDetailProvider(productId));
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        },

        // =========================
        // DATA
        // =========================
        data: (result) {
          final product = result.product;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // OFFLINE BANNER
                // =========================
                if (result.isFromCache)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 20,
                          color: Colors.orange.shade800,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            'Mode hors ligne — données enregistrées localement.',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),

                // =========================
                // IMAGE
                // =========================
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

                // =========================
                // TITLE
                // =========================
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // =========================
                // CATEGORY
                // =========================
                Text(product.category, style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 16),

                // =========================
                // PRICE
                // =========================
                Text(
                  '${product.price.toStringAsFixed(2)} \$',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // =========================
                // RATING
                // =========================
                Text(
                  '⭐ ${product.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 24),

                // =========================
                // DESCRIPTION
                // =========================
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

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
