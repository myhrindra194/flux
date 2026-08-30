import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(HiveBoxes.products);
  }

  static Box get productsBox {
    return Hive.box(HiveBoxes.products);
  }
}
