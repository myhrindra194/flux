import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../models/product_model.dart';

class ProductLocalDataSource {
  Box get _box => Hive.box(HiveBoxes.products);

  Future<void> cacheProducts(List<ProductModel> products) async {
    final data = products
        .map(
          (product) => {
            'id': product.id,
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'rating': product.rating,
            'thumbnail': product.thumbnail,
            'category': product.category,
          },
        )
        .toList();

    await _box.put('products', data);
  }

  List<ProductModel> getCachedProducts() {
    final data = _box.get('products');

    if (data == null) {
      return [];
    }

    final products = data as List;

    return products
        .map(
          (product) =>
              ProductModel.fromJson(Map<String, dynamic>.from(product)),
        )
        .toList();
  }

  Future<void> cacheProduct(ProductModel product) async {
    await _box.put('product_${product.id}', {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'rating': product.rating,
      'thumbnail': product.thumbnail,
      'category': product.category,
    });
  }

  ProductModel? getCachedProduct(int id) {
    final data = _box.get('product_$id');

    if (data == null) {
      return null;
    }

    return ProductModel.fromJson(Map<String, dynamic>.from(data));
  }
}
