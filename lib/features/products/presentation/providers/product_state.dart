import '../../domain/entities/product_entity.dart';

class ProductsState {
  final List<ProductEntity> products;
  final bool isFromCache;

  const ProductsState({required this.products, this.isFromCache = false});
}

class ProductDetailState {
  final ProductEntity product;
  final bool isFromCache;

  const ProductDetailState({required this.product, this.isFromCache = false});
}
