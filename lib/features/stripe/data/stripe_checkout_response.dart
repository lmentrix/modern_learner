class StripeCheckoutResponse {
  const StripeCheckoutResponse({
    required this.url,
    required this.sessionId,
    this.alreadySubscribed = false,
  });

  factory StripeCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return StripeCheckoutResponse(
      url: json['url'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      alreadySubscribed: json['already_subscribed'] as bool? ?? false,
    );
  }

  final String url;
  final String sessionId;
  final bool alreadySubscribed;
}
