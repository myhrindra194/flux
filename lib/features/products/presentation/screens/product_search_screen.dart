import 'package:api/core/errors/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_providers.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      return;
    }

    ref.read(productSearchQueryProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // SEARCH FIELD
            // =========================
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // RESULTS
            // =========================
            Expanded(
              child: productsAsync.when(
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
                              ref.invalidate(productSearchProvider);
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
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text('Aucun produit trouvé.'));
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
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
                            child: Text(
                              '${product.price.toStringAsFixed(2)} \$',
                            ),
                          ),

                          onTap: () {
                            context.push('/products/${product.id}');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
