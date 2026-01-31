class CartItem {
  final String name;
  final int price;
  int qty;
  final String imagePath; // SIMPAN PATH SAJA

  CartItem({
    required this.name,
    required this.price,
    required this.imagePath,
    this.qty = 1,
  });

  int get total => price * qty;
}
