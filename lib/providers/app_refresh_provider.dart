import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to trigger app refresh after sign-in
final appRefreshProvider = StateProvider<int>((ref) => 0);

// Function to refresh the app
void refreshApp(WidgetRef ref) {
  // Increment the refresh counter to trigger rebuild
  ref.read(appRefreshProvider.notifier).state++;
}