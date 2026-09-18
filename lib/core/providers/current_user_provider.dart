import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/login/domain/entities/user_entity.dart';

/// State provider holding the currently logged-in user profile.
final currentUserProvider = StateProvider<UserEntity?>((ref) => null);
