class StripeTransactionDto {
  const StripeTransactionDto({
    required this.id,
    required this.stripeEventType,
    this.userId,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.stripeSessionId,
    this.amountTotal,
    this.currency,
    this.status,
    this.metadata,
    required this.createdAt,
  });

  factory StripeTransactionDto.fromJson(Map<String, dynamic> json) {
    return StripeTransactionDto(
      id: json['id'] as String,
      stripeEventType: json['stripe_event_type'] as String,
      userId: json['user_id'] as String?,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      stripeSubscriptionId: json['stripe_subscription_id'] as String?,
      stripeSessionId: json['stripe_session_id'] as String?,
      amountTotal: (json['amount_total'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String stripeEventType;
  final String? userId;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final String? stripeSessionId;
  final int? amountTotal;
  final String? currency;
  final String? status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
}
