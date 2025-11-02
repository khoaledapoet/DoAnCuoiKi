part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

// Event để bắt đầu lắng nghe danh sách yêu thích
class StartFavoriteListener extends FavoriteEvent {
  final String userId;
  const StartFavoriteListener(this.userId);
  @override
  List<Object> get props => [userId];
}

// Event khi có cập nhật từ Stream (dùng nội bộ trong BLoC)
class _FavoriteUpdated extends FavoriteEvent {
  final List<String> favoritePizzaIds;
  const _FavoriteUpdated(this.favoritePizzaIds);
  @override
  List<Object> get props => [favoritePizzaIds];
}

// Event khi người dùng thêm pizza vào danh sách yêu thích
class AddFavorite extends FavoriteEvent {
  final String pizzaId;
  final String userId;
  const AddFavorite(this.pizzaId, this.userId);
  @override
  List<Object> get props => [pizzaId, userId];
}

// Event khi người dùng xóa pizza khỏi danh sách yêu thích
class RemoveFavorite extends FavoriteEvent {
  final String pizzaId;
  final String userId;
  const RemoveFavorite(this.pizzaId, this.userId);
  @override
  List<Object> get props => [pizzaId, userId];
}

// Event để dừng lắng nghe (khi user đăng xuất)
class StopFavoriteListener extends FavoriteEvent {}
