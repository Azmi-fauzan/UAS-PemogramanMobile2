import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blocs/kasir_cubit.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../blocs/kasir_state.dart';
import '../utils/app.colors.dart';


class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  // ===== SERVICE =====
  late final ProductService productService;
  final supabase = Supabase.instance.client;
  
  // ===== UI STATE =====
  final List<CartItem> cart = [];
  File? pickedImage;

  final nameController = TextEditingController();
  final priceController = TextEditingController();

  final picker = ImagePicker();

  // ===== LIFECYCLE =====
  @override
  void initState() {
    super.initState();
    productService = ProductService(supabase);
    context.read<KasirCubit>().fetchProducts();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // ================= IMAGE PICKER =================
  Future<void> pickImage() async {
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        pickedImage = File(file.path);
      });
    }
  }

  // ================= ADD PRODUCT =================
  Future<void> addItem() async {
    if (pickedImage == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty){ return;}

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final imageUrl =
        await productService.uploadImage(pickedImage!);
    if (imageUrl == null) return;

    await productService.insertProduct(
      name: nameController.text,
      price: int.parse(priceController.text),
      imageUrl: imageUrl,
      userId: user.id,
    );

    if (!mounted) return;

    setState(() {
      pickedImage = null;
      nameController.clear();
      priceController.clear();
    });

    context.read<KasirCubit>().fetchProducts();
  }

  void showAddProductSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga',
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Foto'),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await addItem(); // LOGIC LAMA
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  // ================= CART =================
  int get totalPrice =>
      cart.fold(0, (sum, item) => sum + item.total);

  void addToCart(Product product) {
    setState(() {
      final index =
          cart.indexWhere((e) => e.name == product.name);

      if (index >= 0) {
        cart[index].qty++;
      } else {
        cart.add(
          CartItem(
            name: product.name,
            price: product.price,
            imagePath: product.imageUrl,
            qty: 1,
          ),
        );
      }
    });
  }

  // ================= CART BOTTOM SHEET =================
  void showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
shape: const RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
),

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
  width: 40,
  height: 4,
  margin: const EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(2),
  ),
),
                  const Text(
                    'Keranjang',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: cart.length,
                    itemBuilder: (_, i) {
                      final item = cart[i];
               return ListTile(
  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),

  leading: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      item.imagePath,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    ),
  ),

  title: Text(
    item.name,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
  ),

  subtitle: Text(
    'Rp ${item.price} x ${item.qty}',
    style: TextStyle(
      color: Colors.grey[600],
      fontSize: 13,
    ),
  ),

  trailing: Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF1F3F6),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: () {
            setModalState(() {
              if (item.qty > 1) {
                item.qty--;
              } else {
                cart.remove(item);
              }
            });
          },
        ),
        Text(
          '${item.qty}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: () {
            setModalState(() {
              item.qty++;
            });
          },
        ),
      ],
    ),
  ),
);

                    },
                  ),

                  const Divider(),
                  Text(
                    'Total: Rp $totalPrice',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
          SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5B6CFF),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    onPressed: () async {
       if (cart.isEmpty) return;

    final total = totalPrice; // total cart kamu sekarang

    await supabase.from('transaction').insert({
      'total': total,
    });

    setState(() => cart.clear());
    Navigator.pop(context);
    },
    child: const Text(
      'Checkout',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Kasir'),
        backgroundColor: const Color.fromARGB(255, 51, 84, 217),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [



          // ===== PRODUCT LIST (CUBIT ONLY) =====
          Expanded(
            child: BlocBuilder<KasirCubit, KasirState>(
              builder: (context, state) {
                if (state is KasirLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (state is KasirError) {
                  return Center(
                      child: Text(state.message));
                }

                if (state is KasirLoaded) {
          return GridView.builder(
  padding: const EdgeInsets.all(12),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.75,
  ),
  itemCount: state.products.length,
  itemBuilder: (_, i) {
    final product = state.products[i];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('Rp ${product.price}'),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () => addToCart(product),
            ),
          ),
        ],
      ),
    );
  },
);

                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
floatingActionButton: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    children: [
      // ➕ TAMBAH PRODUK (KIRI)
      Expanded(
        child: SizedBox(
          height: 56,
          child: FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: showAddProductSheet,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
            backgroundColor: AppColors.primary,
          ),
        ),
      ),

      const SizedBox(width: 16),

      // 🛒 KERANJANG (KANAN)
      Expanded(
        child: SizedBox(
          height: 56,
          child: FloatingActionButton.extended(
            heroTag: 'cart',
            onPressed: showCartBottomSheet,
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Keranjang'),
            backgroundColor: AppColors.primary,
          ),
        ),
      ),
    ],
   ),
  )  ,
 floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,





    );
  }
}
