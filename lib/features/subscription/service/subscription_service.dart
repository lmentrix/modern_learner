import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/stripe/service/stripe_service.dart';

export 'package:modern_learner_production/features/stripe/service/stripe_service.dart'
    show AlreadySubscribedException;

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.isVip,
    this.status = 'free',
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.stripePriceId,
  });

  const SubscriptionInfo.free()
    : isVip = false,
      status = 'free',
      currentPeriodEnd = null,
      cancelAtPeriodEnd = false,
      stripePriceId = null;

  final bool isVip;
  final String status;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String? stripePriceId;

  String get statusLabel {
    return switch (status) {
      'active' => 'Active',
      'trialing' => 'Trial',
      'past_due' => 'Past Due',
      'canceled' => 'Canceled',
      'unpaid' => 'Unpaid',
      _ => 'Free',
    };
  }
}

class SubscriptionService {
  SubscriptionService._();

  static final SubscriptionService instance = SubscriptionService._();

  final ValueNotifier<bool> isVip = ValueNotifier<bool>(false);
  final ValueNotifier<SubscriptionInfo> info = ValueNotifier<SubscriptionInfo>(
    const SubscriptionInfo.free(),
  );

  /// Fetches subscription state from both `profiles` and `subscriptions`.
  Future<void> refresh() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      isVip.value = false;
      info.value = const SubscriptionInfo.free();
      return;
    }

    final results = await Future.wait([
      supabase
          .from('profiles')
          .select('role, subscription_status')
          .eq('id', userId)
          .maybeSingle(),
      supabase
          .from('subscriptions')
          .select(
            'status, current_period_end, cancel_at_period_end, stripe_price_id',
          )
          .eq('user_id', userId)
          .maybeSingle(),
    ]);

    final profile = results[0];
    final sub = results[1];

    final vip = profile?['role'] == 'vip';
    final status =
        (sub?['status'] as String?) ??
        (profile?['subscription_status'] as String?) ??
        'free';

    DateTime? periodEnd;
    if (sub?['current_period_end'] != null) {
      periodEnd = DateTime.tryParse(sub!['current_period_end'] as String);
    }

    isVip.value = vip;
    info.value = SubscriptionInfo(
      isVip: vip,
      status: status,
      currentPeriodEnd: periodEnd,
      cancelAtPeriodEnd: (sub?['cancel_at_period_end'] as bool?) ?? false,
      stripePriceId: sub?['stripe_price_id'] as String?,
    );
  }

  /// Creates a Stripe Checkout session via [StripeService].
  /// Returns the checkout URL to open in a browser.
  Future<String> createCheckoutSession() async {
    final session = await StripeService.instance.createCheckoutSession();
    return session.url;
  }
}
