// ignore_for_file: unawaited_futures
import 'package:campus_mesh/screens/auth/demo_login_screen.dart';
import 'package:campus_mesh/screens/auth/register_screen.dart';
import 'package:campus_mesh/screens/home_screen.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/demo_mode_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _demoModeService = DemoModeService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        var errorMessage = 'Failed to sign in';
        var errorDetails = e.toString();

        // Provide more helpful error messages
        if (errorDetails.contains('user-not-found')) {
          errorMessage = 'No account found with this email';
          errorDetails =
              'Please check your email address or register for a new account.';
        } else if (errorDetails.contains('wrong-password')) {
          errorMessage = 'Incorrect password';
          errorDetails = 'Please check your password and try again.';
        } else if (errorDetails.contains('invalid-email')) {
          errorMessage = 'Invalid email address';
          errorDetails = 'Please enter a valid email address.';
        } else if (errorDetails.contains('network')) {
          errorMessage = 'Connection error';
          errorDetails = 'Please check your internet connection and try again.';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(errorMessage),
            content: SelectableText(errorDetails),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surface,
                    scheme.secondaryContainer.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [scheme.primary, scheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school, size: 64, color: Colors.white),
                      ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOut),
                      const SizedBox(height: 28),
                      Text(
                        'RPI Communication',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOut),
                      const SizedBox(height: 10),
                      Text(
                        'Rangpur Government Polytechnic Institute',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: scheme.onSurface.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final url = Uri.parse('https://rangpur.polytech.gov.bd');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          'rangpur.polytech.gov.bd',
                          style: GoogleFonts.inter(
                            color: scheme.primary,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(duration: 550.ms),
                      const SizedBox(height: 42),
                  Semantics(
                    label: 'Email address input field',
                    hint: 'Enter your email address',
                    textField: true,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Password input field',
                    hint: 'Enter your password',
                    textField: true,
                    obscured: _obscurePassword,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: 300.ms,
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Don\'t have an account? Register',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Only show demo mode if available
                  if (_demoModeService.isDemoModeAvailable())
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DemoLoginScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.preview),
                      label: Text(
                        'Try Demo Mode (No Firebase)',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: scheme.primary),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  if (_demoModeService.isDemoModeAvailable())
                    const SizedBox(height: 8),
                  if (_demoModeService.isDemoModeAvailable())
                    Text(
                      'Demo mode: Local sample data only, no real data access',
                      style: GoogleFonts.inter(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}
