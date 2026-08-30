import 'package:api/core/errors/failures.dart';
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
                      ref.invalidate(productsProvider);
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
        data: (state) {
          final products = state.products;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productsProvider);
              await ref.read(productsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // =========================
                // OFFLINE BANNER
                // =========================
                if (state.isFromCache)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange.shade100,
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
                // EMPTY STATE
                // =========================
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: Text('Aucun produit disponible.')),
                  ),

                // =========================
                // PRODUCTS
                // =========================
                ...products.map((product) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () {
                        context.push('/products/${product.id}');
                      },
                      contentPadding: const EdgeInsets.all(12),
                      leading: Image.network(
                        product.thumbnail,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                      title: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('${product.price.toStringAsFixed(2)} \$'),
                      ),
                      trailing: Text('⭐ ${product.rating.toStringAsFixed(1)}'),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
