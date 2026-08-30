import 'package:api/core/errors/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../products/presentation/providers/product_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLX'),
        actions: [
          // Search
          IconButton(
            onPressed: () {
              context.push('/products/search');
            },
            icon: const Icon(Icons.search),
          ),

          // Logout
          IconButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

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
                // WELCOME
                // =========================
                Text(
                  'Bienvenue sur FLX 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(user?.email ?? ''),

                const SizedBox(height: 24),

                // =========================
                // PRODUCTS TITLE
                // =========================
                Text(
                  'Produits',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

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
                        width: 70,
                        height: 70,
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
