
import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:flutter_chat/core/supabase/repository/supabase_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'supabase_repository_provider.g.dart';

@riverpod
SupabaseRepository supabaseRepository(Ref ref) => SupabaseRepositoryImpl();
