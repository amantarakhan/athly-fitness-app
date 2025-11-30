import 'package:athlynew/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _sendLink() async {
  // 1) Close the keyboard
  FocusScope.of(context).unfocus();

  // 2) Validate
  final form = _formKey.currentState;
  if (form == null) return;
  if (!form.validate()) return;

  final email = _emailCtrl.text.trim();

  try {
    // TODO: backend call later (await yourAuth.reset(email))
    // Simulate a short delay to mimic a real call
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return; // 3) Guard against unmounted context

    // 4) Show success
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Reset link sent to $email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  } catch (e, st) {
    // 5) Surface any errors instead of crashing
    debugPrint('Reset error: $e\n$st');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong. Please try again.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ▼ Illustration placed low & centered (not at top), subtle glow
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.75,
                  child: Column(
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/meditation.png', // put your file here
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            // ▼ Foreground content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Reset Password',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800, // like your “Create Account”
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter the email you used to sign up. We'll send you a secure link to create a new password.",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.alternate_email_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: cs.primary),
                          ),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Email is required';
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _sendLink(),
                      ),

                      const SizedBox(height: 20),

                      // Send link button (navy style like your screenshot)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _sendLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy, // your navy
                            shadowColor: Colors.black26,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child:  const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              color: Colors.white ,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Back to login (orange link like your style)
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Remember your password? ",
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: 'Log In',
                                style: const TextStyle(
                                  color: Colors.orange, // your accent
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context); // back to login
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
