import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import 'kasir_state.dart';

class KasirCubit extends Cubit<KasirState> {
  KasirCubit() : super(KasirInitial());

  final supabase = Supabase.instance.client;

  Future<void> fetchProducts() async {
    emit(KasirLoading());

    final user = supabase.auth.currentUser;
    if (user == null) {
      emit(KasirError('User belum login'));
      return;
    }

    try {
      final res = await supabase
          .from('product')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final products = res
          .map<Product>((e) => Product(
                id: e['id'],
                name: e['name'],
                price: e['price'],
                imageUrl: e['image_url'],
              ))
          .toList();

      emit(KasirLoaded(products));
    } catch (e) {
      emit(KasirError(e.toString()));
    }
  }
}
