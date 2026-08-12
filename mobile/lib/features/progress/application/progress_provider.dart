import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/gamification_models.dart';
import '../../../data/models/progress_models.dart';

final progressOverviewProvider = FutureProvider<ProgressOverview>((ref) async {
  return ref.watch(apiClientProvider).fetchProgressOverview();
});

final gamificationOverviewProvider = FutureProvider<GamificationOverview>((ref) async {
  return ref.watch(apiClientProvider).fetchGamificationOverview();
});
