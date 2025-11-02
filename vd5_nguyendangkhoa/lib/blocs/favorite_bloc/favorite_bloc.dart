import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final UserRepository _userRepository;
  StreamSubscription? _favoriteSubscription;

  FavoriteBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const FavoriteState()) {
    // Đăng ký các hàm xử lý event
    on<StartFavoriteListener>(_onStartFavoriteListener);
    on<_FavoriteUpdated>(_onFavoriteUpdated);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<StopFavoriteListener>(_onStopFavoriteListener);
  }

  // Bắt đầu lắng nghe stream danh sách yêu thích
  void _onStartFavoriteListener(
    StartFavoriteListener event,
    Emitter<FavoriteState> emit,
  ) {
    emit(state.copyWith(status: FavoriteStatus.loading));
    _favoriteSubscription?.cancel();
    _favoriteSubscription = _userRepository
        .getFavoritePizzaIds(event.userId)
        .listen(
          (pizzaIds) {
            add(_FavoriteUpdated(pizzaIds));
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: FavoriteStatus.error,
                error: error.toString(),
              ),
            );
          },
        );
  }

  // Cập nhật state khi stream có dữ liệu mới
  void _onFavoriteUpdated(_FavoriteUpdated event, Emitter<FavoriteState> emit) {
    emit(
      state.copyWith(
        status: FavoriteStatus.loaded,
        favoritePizzaIds: event.favoritePizzaIds,
      ),
    );
  }

  // Thêm pizza vào danh sách yêu thích
  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await _userRepository.addFavorite(event.userId, event.pizzaId);
    } catch (e) {
      emit(state.copyWith(status: FavoriteStatus.error, error: e.toString()));
    }
  }

  // Xóa pizza khỏi danh sách yêu thích
  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await _userRepository.removeFavorite(event.userId, event.pizzaId);
    } catch (e) {
      emit(state.copyWith(status: FavoriteStatus.error, error: e.toString()));
    }
  }

  // Dừng lắng nghe stream
  void _onStopFavoriteListener(
    StopFavoriteListener event,
    Emitter<FavoriteState> emit,
  ) {
    _favoriteSubscription?.cancel();
    _favoriteSubscription = null;
    emit(const FavoriteState()); // Reset về trạng thái ban đầu
  }

  // Override hàm close
  @override
  Future<void> close() {
    _favoriteSubscription?.cancel();
    return super.close();
  }
}
