import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatSearchProvider =
    NotifierProvider.family<ChatSearchController, ChatSearchState, String>(
      ChatSearchController.new,
    );

class ChatSearchState {
  const ChatSearchState({
    this.isSearching = false,
    this.query = '',
    this.selectedIndex = 0,
  });

  final bool isSearching;
  final String query;
  final int selectedIndex;

  ChatSearchState copyWith({
    bool? isSearching,
    String? query,
    int? selectedIndex,
  }) {
    return ChatSearchState(
      isSearching: isSearching ?? this.isSearching,
      query: query ?? this.query,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class ChatSearchController extends Notifier<ChatSearchState> {
  ChatSearchController(this.remoteDeviceId);

  final String remoteDeviceId;

  @override
  ChatSearchState build() {
    return const ChatSearchState();
  }

  void toggle() {
    if (state.isSearching) {
      state = const ChatSearchState();
      return;
    }
    state = state.copyWith(isSearching: true, selectedIndex: 0);
  }

  void updateQuery(String value) {
    state = state.copyWith(query: value, selectedIndex: 0);
  }

  void previous(int matchCount) {
    if (matchCount <= 0) {
      return;
    }
    final nextIndex = (state.selectedIndex - 1) % matchCount;
    state = state.copyWith(
      selectedIndex: nextIndex < 0 ? matchCount - 1 : nextIndex,
    );
  }

  void next(int matchCount) {
    if (matchCount <= 0) {
      return;
    }
    state = state.copyWith(
      selectedIndex: (state.selectedIndex + 1) % matchCount,
    );
  }
}
