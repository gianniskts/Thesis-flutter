import 'package:flutter/cupertino.dart';

import 'store.dart';

class Item {
  final Store store;
  final String product;
  final String time;
  final String oldPrice;
  final String newPrice;
  final String distance;
  final String description;
  final VoidCallback onTapFavorite;
  final bool isFavorite;

  const Item({
    required this.store,
    required this.product,
    required this.time,
    required this.oldPrice,
    required this.newPrice,
    required this.distance,
    required this.description,
    required this.onTapFavorite,
    required this.isFavorite,
  });
}