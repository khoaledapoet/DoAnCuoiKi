part of 'favorite_bloc.dart';

// Trạng thái của danh sách yêu thích
enum FavoriteStatus { initial, loading, loaded, error }

class FavoriteState extends Equatable {
  final FavoriteStatus status;
  final List<String> favoritePizzaIds; // Danh sách ID của pizza yêu thích
  final String? error;

  const FavoriteState({
    this.status = FavoriteStatus.initial,
    this.favoritePizzaIds = const <String>[],
    this.error,
  });

  // Kiểm tra xem pizza có được yêu thích hay không
  bool isFavorite(String pizzaId) => favoritePizzaIds.contains(pizzaId);

  FavoriteState copyWith({
    FavoriteStatus? status,
    List<String>? favoritePizzaIds,
    String? error,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      favoritePizzaIds: favoritePizzaIds ?? this.favoritePizzaIds,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, favoritePizzaIds, error];
}
