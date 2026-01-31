import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProductService {
  final SupabaseClient supabase;

  ProductService(this.supabase);

  Future<String?> uploadImage(File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    await supabase.storage.from('product-images').upload(fileName, file);

    return supabase.storage.from('product-images').getPublicUrl(fileName);
  }

  Future<void> insertProduct({
    required String name,
    required int price,
    required String imageUrl,
    required String userId,
  }) async {
    await supabase.from('product').insert({
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'user_id': userId,
    });
  }
}
