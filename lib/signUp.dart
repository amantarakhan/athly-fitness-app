import 'package:athlynew/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final f = _formKey.currentState;
    if (f == null || !f.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    // ✅ Use named route (as requested)
    Navigator.pushNamed(context, '/goal');
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textDark.withOpacity(.7)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textDark.withOpacity(.25), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textDark.withOpacity(.25), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textDark.withOpacity(.55), width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

     
      body: Stack(
        children: [
           const SizedBox(height: 100 ) , 

          // 🖼️ Watermark illustration (slightly stronger than login)
          Positioned(
            top: 0,
            right: -10,
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.25, // clearer than login page
                child: Image.asset(
                  'assets/images/cyclist.png', // ✅ your image path
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 150),

                    // Heading
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Join Athly and start your journey!",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full Name
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _dec('Full Name', Icons.person_outline_rounded),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Full name is required';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _dec('Email', Icons.alternate_email_rounded),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Email is required';
                        if (!s.contains('@') || !s.contains('.')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _dec(
                        'Password',
                        Icons.lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: AppColors.textDark.withOpacity(.7),
                          ),
                        ),
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Password is required';
                        if (s.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 36),

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Already have an account
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "Log In",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pushNamed(context, '/login'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Terms & Conditions
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text.rich(
                          TextSpan(
                            text: "By signing up, you agree to our ",
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54,
                              fontFamily: "Poppins",
                            ),
                            children: [
                              TextSpan(
                                text: "Terms & Conditions",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy.",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
