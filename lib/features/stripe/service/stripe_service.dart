import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/stripe/data/stripe_checkout_response.dart';
import 'package:modern_learner_production/features/stripe/data/stripe_transaction_dto.dart';
import 'package:modern_learner_production/features/stripe/model/stripe_checkout_session.dart';
import 'package:modern_learner_production/features/stripe/model/stripe_transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlreadySubscribedException implements Exception {
  @override
  String toString() => 'Already subscribed';
}

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  /// Calls the `create-checkout-session` Edge Function and returns the session.
  /// Throws [AlreadySubscribedException] if the user is already a VIP.
  Future<StripeCheckoutSession> createCheckoutSession() async {
    final session = supabase.auth.currentSession;
    if (session == null) throw Exception('Not authenticated');

    try {
      debugPrint('[StripeService] Invoking create-checkout-session...');
      final response = await supabase.functions.invoke(
        'create-checkout-session',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      debugPrint('[StripeService] Response status: ${response.status}');
      debugPrint('[StripeService] Response data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final dto = StripeCheckoutResponse.fromJson(data);

      if (dto.alreadySubscribed) throw AlreadySubscribedException();
      if (dto.url.isEmpty) throw Exception('No checkout URL returned');

      return StripeCheckoutSession(url: dto.url, sessionId: dto.sessionId);
    } on FunctionException catch (e) {
      debugPrint(
        '[StripeService] FunctionException — status: ${e.status}, details: ${e.details}',
      );
      final detail = e.details?.toString() ?? e.toString();
      throw Exception('Checkout failed: $detail');
    }
  }

  /// Returns the current user's Stripe transaction history from Supabase.
  Future<List<StripeTransaction>> getTransactions({int limit = 20}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await supabase
        .from('stripe_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List)
        .map(
          (r) => _toModel(
            StripeTransactionDto.fromJson(r as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  StripeTransaction _toModel(StripeTransactionDto dto) {
    return StripeTransaction(
      id: dto.id,
      eventType: dto.stripeEventType,
      createdAt: dto.createdAt,
      amountTotal: dto.amountTotal,
      currency: dto.currency,
      status: dto.status,
      stripeCustomerId: dto.stripeCustomerId,
      stripeSubscriptionId: dto.stripeSubscriptionId,
    );
  }
}
