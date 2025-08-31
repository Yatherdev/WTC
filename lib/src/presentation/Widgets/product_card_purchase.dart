import 'package:flutter/material.dart';
import '../../domain/models/purchase.dart';

class ProductCard extends StatelessWidget {
  final Purchase product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(product.sawType),
        subtitle: Text('التكعيب: ${product.volume.toStringAsFixed(2)} m³ - السعر: ${product.price.toStringAsFixed(2)} ج.م'),
        trailing: Text(product.date.toLocal().toString().split(' ')[0]),
      ),
    );
  }
}