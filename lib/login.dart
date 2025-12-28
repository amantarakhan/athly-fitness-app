import 'package:athlynew/AppShell.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

Future<void> login() async { 
try { 
final userCredential = await FirebaseAuth.instance 
.signInWithEmailAndPassword( 
email: _emailCtrl.text.trim(), 
password: _passwordCtrl.text.trim()); 
} catch (e) { 
} 
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
      // Use pure white for a crisp form; swap to AppColors.background if you prefer cream.
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 🌫️ Watermark (soft, non-interactive)
          Positioned(
            top: 12,
            right: -10, // a tiny negative pushes it off-edge for a designer look
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.25, // subtle
                child: Image.asset(
                  'assets/images/runners.png',
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),

                    // Heading
                    const Text(
                      "Hey,",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Login Now!",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Helper row
                    Row(
                      children: [
                        const Text(
                          "I am an old user",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            "Create New",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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

                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                          text: "Forget Password? ",
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "Reset",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                               ..onTap = () {
      // 👇 REPLACE this line
      Navigator.pushNamed(context, '/reset');
    },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Log In button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : login  ,
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
                                width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                "Login Now",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Guest link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                        child: Text(
                          "Skip Now",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
Center(
  child: Text(
    "Every step counts — keep moving!",
    style: TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.w500,
      fontSize: 13,
      fontStyle: FontStyle.italic,
      color: AppColors.textDark.withOpacity(0.6),
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
