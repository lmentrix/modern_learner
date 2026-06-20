import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/auth/bloc/auth_bloc.dart';
import 'package:modern_learner_production/auth/section/auth_sign_in_form.dart';
import 'package:modern_learner_production/auth/section/auth_sign_up_form.dart';
import 'package:modern_learner_production/auth/section/logo_section.dart';
import 'package:modern_learner_production/auth/service/auth_service.dart';
import 'package:modern_learner_production/auth/widgets/auth_submit_button.dart';
import 'package:modern_learner_production/auth/widgets/auth_tab_switcher.dart';
import 'package:modern_learner_production/auth/widgets/auth_toggle_link.dart';
import 'package:modern_learner_production/auth/widgets/background_blob.dart';
import 'package:modern_learner_production/theme/theme.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authService: AuthService()),
      child: const _AuthView(),
    );
  }
}

// ── View ─────────────────────────────────────────────────────────────────────

class _AuthView extends StatefulWidget {
  const _AuthView();

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> with TickerProviderStateMixin {
  AuthMode _mode = AuthMode.signIn;

  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  // Form
  final _signInKey = GlobalKey<FormState>();
  final _signUpKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;

  // Focus
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
          ),
        );
    _formFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.28, 1.0, curve: Curves.easeOut),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.28, 1.0, curve: Curves.easeOut),
          ),
        );

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
      _obscure = true;
    });
  }

  void _submit() {
    final bloc = context.read<AuthBloc>();
    if (_mode == AuthMode.signIn) {
      if (_signInKey.currentState?.validate() ?? false) {
        bloc.add(
          SignInUser(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          ),
        );
      }
    } else {
      if (_signUpKey.currentState?.validate() ?? false) {
        bloc.add(
          SignUpUser(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: EduColors.bg,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              const BackgroundBlobs(),

              SafeArea(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: EduSpacing.s6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: EduSpacing.s12),

                      // Logo / brand
                      FadeTransition(
                        opacity: _logoFade,
                        child: SlideTransition(
                          position: _logoSlide,
                          child: const LogoSection(),
                        ),
                      ),

                      const SizedBox(height: EduSpacing.s10),

                      // Form card
                      FadeTransition(
                        opacity: _formFade,
                        child: SlideTransition(
                          position: _formSlide,
                          child: Container(
                            padding: const EdgeInsets.all(EduSpacing.s6),
                            decoration: BoxDecoration(
                              color: EduColors.surface,
                              borderRadius: EduRadius.borderXl,
                              boxShadow: EduColors.shadowRaised,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AuthTabSwitcher(
                                  mode: _mode,
                                  onSwitch: _switchMode,
                                ),

                                const SizedBox(height: EduSpacing.s6),

                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                        opacity: anim,
                                        child: child,
                                      ),
                                  child: _mode == AuthMode.signIn
                                      ? AuthSignInForm(
                                          key: const ValueKey('si'),
                                          formKey: _signInKey,
                                          emailCtrl: _emailCtrl,
                                          passCtrl: _passCtrl,
                                          emailFocus: _emailFocus,
                                          passFocus: _passFocus,
                                          obscure: _obscure,
                                          onToggle: () => setState(
                                            () => _obscure = !_obscure,
                                          ),
                                          onSubmit: _submit,
                                        )
                                      : AuthSignUpForm(
                                          key: const ValueKey('su'),
                                          formKey: _signUpKey,
                                          nameCtrl: _nameCtrl,
                                          emailCtrl: _emailCtrl,
                                          passCtrl: _passCtrl,
                                          emailFocus: _emailFocus,
                                          passFocus: _passFocus,
                                          obscure: _obscure,
                                          onToggle: () => setState(
                                            () => _obscure = !_obscure,
                                          ),
                                          onSubmit: _submit,
                                        ),
                                ),

                                const SizedBox(height: EduSpacing.s5),

                                AuthSubmitButton(
                                  mode: _mode,
                                  loading: isLoading,
                                  onPressed: isLoading ? null : () => _submit(),
                                ),

                                if (_mode == AuthMode.signIn) ...[
                                  const SizedBox(height: EduSpacing.s2),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Forgot password?',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: EduColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: EduSpacing.s5),

                      FadeTransition(
                        opacity: _formFade,
                        child: AuthToggleLink(
                          mode: _mode,
                          onSwitch: _switchMode,
                        ),
                      ),

                      const SizedBox(height: EduSpacing.s16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
