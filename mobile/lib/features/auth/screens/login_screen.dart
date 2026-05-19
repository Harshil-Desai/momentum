import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    final success = await ref.read(authProvider.notifier).login(email, password);
    if (success && mounted) context.go('/habits');
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final authState = ref.watch(authProvider).valueOrNull ?? const AuthState();

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 88),
                    Text(
                      'Cadence',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fraunces(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: mc.inkPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Small steps. Real change.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: mc.inkTertiary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 60),
                    _UnderlineField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 28),
                    _UnderlineField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    if (authState.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authState.error!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: mc.danger,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),
                    _InkButton(
                      label: 'Sign in',
                      loading: authState.isLoading,
                      onTap: _submit,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: 'New here? ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: mc.inkTertiary,
                                letterSpacing: -0.1,
                              ),
                            ),
                            TextSpan(
                              text: 'Begin.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: mc.inkSecondary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                'Habits are just decisions\nyou\'ve already made.',
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: mc.inkTertiary,
                  letterSpacing: -0.1,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Underline text field ───────────────────────────────────────────────────────

class _UnderlineField extends StatefulWidget {
  const _UnderlineField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.borderColorOverride,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color? borderColorOverride;

  @override
  State<_UnderlineField> createState() => _UnderlineFieldState();
}

class _UnderlineFieldState extends State<_UnderlineField> {
  late FocusNode _focus;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _obscure = widget.obscureText;
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final isFocused = _focus.hasFocus;
    final activeBorder = widget.borderColorOverride ??
        (isFocused ? mc.inkPrimary : mc.hairlineStrong);
    final floatingColor = widget.borderColorOverride ??
        (isFocused ? mc.inkSecondary : mc.inkTertiary);

    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscure,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: mc.inkPrimary,
        letterSpacing: -0.1,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: mc.inkTertiary,
          letterSpacing: -0.1,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          color: floatingColor,
          letterSpacing: 0.2,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: mc.hairlineStrong, width: 1),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColorOverride ?? mc.hairlineStrong,
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: activeBorder, width: 1.5),
        ),
        contentPadding: const EdgeInsets.only(bottom: 12, top: 4),
        isDense: true,
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: mc.inkTertiary,
                  ),
                ),
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}

// ── Ink button ─────────────────────────────────────────────────────────────────

class _InkButton extends StatelessWidget {
  const _InkButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: loading ? mc.inkPrimary.withAlpha(140) : mc.inkPrimary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: mc.bgCanvas,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: mc.bgCanvas,
                    letterSpacing: -0.1,
                  ),
                ),
        ),
      ),
    );
  }
}
