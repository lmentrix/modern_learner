import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/stripe/service/stripe_service.dart';
import 'package:modern_learner_production/features/subscription/service/subscription_service.dart';
import 'package:modern_learner_production/features/subscription/view/subscription_transaction_history.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with WidgetsBindingObserver {
  bool _subscribing = false;
  bool _didLaunchCheckout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
    Future<void>.delayed(const Duration(seconds: 2), _refreshStatus);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // When the user returns from the browser (Stripe Checkout), refresh status.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _didLaunchCheckout) {
      _didLaunchCheckout = false;
      _refreshStatus();
    }
  }

  Future<void> _refreshStatus() async {
    await SubscriptionService.instance.refresh();
    if (!mounted) return;
    if (SubscriptionService.instance.isVip.value) {
      _showSuccessSnackbar();
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              'Welcome to VIP! Enjoy premium access.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _subscribe() async {
    debugPrint('[Subscribe] Button pressed');
    setState(() => _subscribing = true);
    try {
      debugPrint('[Subscribe] Calling createCheckoutSession...');
      final session = await StripeService.instance.createCheckoutSession();
      debugPrint(
        '[Subscribe] Session received — url: ${session.url}, id: ${session.sessionId}',
      );
      final uri = Uri.parse(session.url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('[Subscribe] launchUrl: $launched');
      if (launched) {
        _didLaunchCheckout = true;
        debugPrint('[Subscribe] Launched checkout URL');
      } else {
        debugPrint('[Subscribe] ERROR: Could not launch URL: $uri');
        _showError('Could not open the payment page. Please try again.');
      }
    } on AlreadySubscribedException {
      debugPrint('[Subscribe] User is already subscribed');
      if (mounted) _showSuccessSnackbar();
    } catch (e, stack) {
      debugPrint('[Subscribe] ERROR: $e');
      debugPrint('[Subscribe] Stack trace:\n$stack');
      if (mounted) _showError('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _subscribing = false);
      debugPrint('[Subscribe] Done (subscribing = false)');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ValueListenableBuilder<SubscriptionInfo>(
          valueListenable: SubscriptionService.instance.info,
          builder: (context, info, _) {
            final isVip = info.isVip;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, isVip)),
                SliverToBoxAdapter(
                  child: isVip
                      ? _buildActiveSubscription(info)
                      : _buildPlanCard(),
                ),
                if (!isVip) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(child: _buildFeatureList()),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                if (!isVip) SliverToBoxAdapter(child: _buildSubscribeButton()),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildFooter(info)),
                if (isVip) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  const SliverToBoxAdapter(
                    child: SubscriptionTransactionHistory(),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isVip) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: 14),
          Text(
            'Subscription',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          if (isVip) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '👑 ACTIVE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1228), Color(0xFF231638)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👑', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP Member',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    Text(
                      'Unlock the full learning experience',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$9.99',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '/ month',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              'Cancel anytime · No hidden fees',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscription(SubscriptionInfo info) {
    final periodEnd = info.currentPeriodEnd;
    final formattedEnd = periodEnd != null ? _formatDate(periodEnd) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1228), Color(0xFF231638)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('👑', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'You\'re a VIP Member!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFFD700),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Thank you for your support. Enjoy all premium features.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${info.statusLabel}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
            // Billing period
            if (formattedEnd != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                label: info.cancelAtPeriodEnd ? 'Access until' : 'Renews on',
                value: formattedEnd,
              ),
            ],
            if (info.cancelAtPeriodEnd) ...[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your subscription will not renew after this period.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    const features = [
      (
        Icons.all_inclusive_rounded,
        'Unlimited AI Lessons',
        'Access every lesson with no daily caps',
      ),
      (
        Icons.auto_awesome_rounded,
        'Advanced AI Tutor',
        'Smarter feedback and personalized paths',
      ),
      (
        Icons.bar_chart_rounded,
        'Detailed Analytics',
        'Track every metric of your learning journey',
      ),
      (
        Icons.offline_bolt_rounded,
        'Offline Access',
        'Download lessons and study anywhere',
      ),
      (
        Icons.support_agent_rounded,
        'Priority Support',
        'Get help from our team within hours',
      ),
      (
        Icons.new_releases_rounded,
        'Early Access',
        'Be first to try new features and courses',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT\'S INCLUDED',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeatureRow(icon: f.$1, title: f.$2, subtitle: f.$3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _subscribing ? null : _subscribe,
            child: Center(
              child: _subscribing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Subscribe · \$9.99/mo',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(SubscriptionInfo info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (!info.isVip) ...[
            GestureDetector(
              onTap: _refreshStatus,
              child: Text(
                'Restore Purchase',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: 12),
          ],
          Text(
            'Payment processed securely by Stripe.\nSubscription renews automatically. Cancel anytime.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFFFFD700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }
}
