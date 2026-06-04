class StripeTransaction {
  const StripeTransaction({
    required this.id,
    required this.eventType,
    required this.createdAt,
    this.amountTotal,
    this.currency,
    this.status,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
  });

  final String id;
  final String eventType;
  final DateTime createdAt;
  final int? amountTotal;
  final String? currency;
  final String? status;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;

  double? get amountInDollars =>
      amountTotal != null ? amountTotal! / 100.0 : null;

  String get eventLabel => switch (eventType) {
    'checkout.session.completed' => 'Subscription Started',
    'customer.subscription.updated' => 'Subscription Updated',
    'customer.subscription.deleted' => 'Subscription Canceled',
    'invoice.payment_failed' => 'Payment Failed',
    'invoice.payment_succeeded' => 'Payment Succeeded',
    _ => eventType,
  };

  String get statusLabel => switch (status) {
    'succeeded' => 'Succeeded',
    'failed' => 'Failed',
    'pending' => 'Pending',
    'active' => 'Active',
    'canceled' => 'Canceled',
    _ => status ?? '—',
  };

  bool get isFailure =>
      status == 'failed' || eventType == 'invoice.payment_failed';
}
