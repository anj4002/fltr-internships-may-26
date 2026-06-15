import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import 'models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductRepository {
  final _random = Random();

  static final List<Product> _catalogue = [
    const Product(
      id: 'p1',
      name: 'Wireless Noise-Cancelling Headphones',
      description:
          'Premium over-ear headphones with 30h battery life, active noise '
          'cancellation, and foldable design.',
      price: 149.99,
      imageUrl: 'https://picsum.photos/seed/headphones/400/300',
      category: 'Electronics',
      stockCount: 42,
    ),
    const Product(
      id: 'p2',
      name: 'Minimalist Leather Wallet',
      description: 'Slim bifold wallet in full-grain leather. '
          'Holds up to 8 cards with RFID blocking.',
      price: 39.99,
      imageUrl: 'https://picsum.photos/seed/wallet/400/300',
      category: 'Accessories',
      stockCount: 120,
    ),
    const Product(
      id: 'p3',
      name: 'Ceramic Pour-Over Coffee Set',
      description: 'Hand-thrown ceramic dripper with matching mug. '
          'Perfect for slow-brew coffee enthusiasts.',
      price: 54.99,
      imageUrl: 'https://picsum.photos/seed/coffeeset/400/300',
      category: 'Kitchen',
      stockCount: 35,
    ),
    const Product(
      id: 'p4',
      name: 'Mechanical Keyboard 65%',
      description: 'Compact TKL keyboard with hot-swappable switches, '
          'RGB backlight, and aluminium frame.',
      price: 119.99,
      imageUrl: 'https://picsum.photos/seed/keyboard/400/300',
      category: 'Electronics',
      stockCount: 18,
    ),
    const Product(
      id: 'p5',
      name: 'Bamboo Desk Organiser',
      description: 'Eco-friendly 5-slot desk organiser. '
          'Sustainably sourced bamboo, natural finish.',
      price: 24.99,
      imageUrl: 'https://picsum.photos/seed/organiser/400/300',
      category: 'Home Office',
      stockCount: 67,
    ),
    const Product(
      id: 'p6',
      name: 'Stainless Steel Water Bottle 1L',
      description: 'Vacuum-insulated bottle keeps drinks cold 24h / hot 12h. '
          'BPA-free, leak-proof lid.',
      price: 29.99,
      imageUrl: 'https://picsum.photos/seed/bottle/400/300',
      category: 'Sports',
      stockCount: 200,
    ),
    const Product(
      id: 'p7',
      name: 'Merino Wool Running Socks (3-pack)',
      description: 'Anti-blister performance socks with arch support '
          'and moisture-wicking finish.',
      price: 18.99,
      imageUrl: 'https://picsum.photos/seed/socks/400/300',
      category: 'Sports',
      stockCount: 95,
    ),
    const Product(
      id: 'p8',
      name: 'Portable Bluetooth Speaker',
      description: 'IPX7 waterproof speaker with 360° sound and 12h playtime. '
          'Fits in a cup holder.',
      price: 69.99,
      imageUrl: 'https://picsum.photos/seed/speaker/400/300',
      category: 'Electronics',
      stockCount: 55,
    ),
    const Product(
      id: 'p9',
      name: 'Linen Throw Pillow Cover',
      description:
          'Textured linen cover with hidden zip, 18×18 in. Available '
          'in stone, sage, and terracotta.',
      price: 14.99,
      imageUrl: 'https://picsum.photos/seed/pillow/400/300',
      category: 'Home',
      stockCount: 140,
    ),
    const Product(
      id: 'p10',
      name: 'Cast Iron Skillet 10"',
      description: 'Pre-seasoned cast iron with helper handle. '
          'Works on all cooktops including induction.',
      price: 34.99,
      imageUrl: 'https://picsum.photos/seed/skillet/400/300',
      category: 'Kitchen',
      stockCount: 60,
    ),
  ];

  Future<List<Product>> fetchProducts({int page = 0}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_random.nextDouble() < 0.05) {
      throw const AppException(
        message: 'Network error: failed to load products. Please try again.',
        statusCode: 503,
      );
    }

    final start = page * AppConstants.productsPerPage;
    if (start >= _catalogue.length) return [];
    final end =
        (start + AppConstants.productsPerPage).clamp(0, _catalogue.length);
    return _catalogue.sublist(start, end);
  }
}
