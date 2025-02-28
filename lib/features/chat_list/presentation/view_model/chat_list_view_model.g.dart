// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatListViewModelHash() => r'a9bddb84a905ea734a6d70198f3f0b48e76a6f11';

/// See also [ChatListViewModel].
@ProviderFor(ChatListViewModel)
final chatListViewModelProvider = AutoDisposeStreamNotifierProvider<
    ChatListViewModel, List<(ChatDto, UserDto)>>.internal(
  ChatListViewModel.new,
  name: r'chatListViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatListViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatListViewModel
    = AutoDisposeStreamNotifier<List<(ChatDto, UserDto)>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
