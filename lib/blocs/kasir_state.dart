abstract class KasirState {}

class KasirInitial extends KasirState {}

class KasirLoading extends KasirState {}

class KasirLoaded extends KasirState {
  final List products;
  KasirLoaded(this.products);
}

class KasirError extends KasirState {
  final String message;
  KasirError(this.message);
}
