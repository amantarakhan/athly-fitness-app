import 'package:athlynew/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athlynew/goalSetting.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // these are same as the login controlers 
  final _formKey = GlobalKey<FormState>();
  // but here we have a name which handle the user name that will be in both the profile and the home 
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  // for the password icon 
  bool _obscure = true;
  // disable button when the inputs is wrong 
  bool _isSubmitting = false;

// same -  release resources such as TextEditingControllers when 
//the widget is removed from the widget tree
// good for the memory 
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

// an UI helper to enture consistency - same as the one in the login 
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
        borderSide: BorderSide(
          color: AppColors.textDark.withOpacity(.25),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.textDark.withOpacity(.25),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.textDark.withOpacity(.55),
          width: 1.6,
        ),
      ),
    );
  }

// here is the signup method that will be called when the user press sign up - async cuz its waitig for the Firebase authentication 
  Future<void> signUp() async {
    print('\n🟦🟦🟦 SIGNUP STARTED 🟦🟦🟦');// in the console
    
    if (_isSubmitting) { // if the user press sign up multiple time 
    // if its true -> exit immerdiatly 
      print('⚠️ Already submitting, ignoring duplicate call');
      return;
    }
// colse the keyboard - imporve the UX 
    FocusScope.of(context).unfocus();

// from validation 
    final form = _formKey.currentState; // gets the current form satate
    if (form == null || !form.validate()) { // runs the validators and make sure there arent null 
      print('❌ Form validation failed');
      return; // exist 
    }


    setState(() => _isSubmitting = true); // become loading - locks the UI until the proccess finish 
    print('✅ Form validated, starting signup process...');

    try { // reomve spaces form all inputs 
      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();
      // read the user input - print in the console
      print('📝 Name: $name');
      print('📧 Email: $email');
      print('🔒 Password length: ${password.length}');
      
      // STEP 1: Create Firebase Auth user -wait for the Firebase 
      print('\n🔵 STEP 1: Creating Firebase Auth user...');
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // validator - its not null 
      final user = userCredential.user;
      if (user == null) {
        throw Exception('User is null after creation');
      }
      // else case - not null -> complete 
      print('✅ User created! UID: ${user.uid}');

      // STEP 2: Update display name - for later so the user name display in the profile + home 
      print('\n🔵 STEP 2: Updating display name...');
      await user.updateDisplayName(name); // the name the user enter 
      print('✅ Display name set to: $name');

      // STEP 3: Save to Firestore
      print('\n🔵 STEP 3: Saving to Firestore...');
      try {
        await FirebaseFirestore.instance // wait for the fireBase 
        // this create a user object on the Firebase with ID that have  ( name - email - time created at ) 
            .collection('users')
            .doc(user.uid)
            .set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Firestore document created successfully!');
      } catch (firestoreError) {
        print('❌ FIRESTORE ERROR: $firestoreError');
        // Don't throw - continue even if Firestore fails
        // The user account is already created
      }

      // STEP 4: Reload user - refresh the Firebase Auth data 
      print('\n🔵 STEP 4: Reloading user...');
      await user.reload();
      final freshUser = FirebaseAuth.instance.currentUser;
      print('✅ User reloaded. DisplayName: ${freshUser?.displayName}'); // ensure the name is available 

      // STEP 5: Check if widget is still mounted
      //true → widget is still alive on the screen
      //// false → widget has been removed (disposed)
      if (!mounted) {
        print('⚠️ Widget not mounted, cannot show UI updates');
        return;
      }

      // STEP 6: Show success message - snack bar 
      print('\n🔵 STEP 5: Showing success message...');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Welcome, $name!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      print('✅ SnackBar shown'); // in the consol 

      // STEP 7: Wait a bit
      print('\n🔵 STEP 6: Waiting 500ms before navigation...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) {
        print('⚠️ Widget not mounted after delay, cannot navigate');
        return;
      }

      // STEP 8: Navigate
      print('\n🔵 STEP 7: Navigating to goal setting...');
      print('Current route: ${ModalRoute.of(context)?.settings.name}');
      
      Navigator.pushReplacement( // replace the sign up screen with the goalSettings - no going back 
        context,
        MaterialPageRoute(
          builder: (context) => const GoalSettingScreen(),
        ),
      );

      print('✅ Navigation method called!');
      print('🟩🟩🟩 SIGNUP COMPLETED SUCCESSFULLY! 🟩🟩🟩\n');



    } on FirebaseAuthException catch (e) { // error handling 
      print('\n❌❌❌ FIREBASE AUTH EXCEPTION ❌❌❌');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('Stack: ${e.stackTrace}');
      
      if (!mounted) return;
      
      String message = 'Sign up failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else {
        message = 'Sign up failed: ${e.message}';
      }
    // in failure feedback - snackbar 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e, stackTrace) {
      print('\n❌❌❌ UNEXPECTED ERROR ❌❌❌');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('StackTrace: $stackTrace');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally { // always runs - cleanup 
      print('\n🔵 Resetting _isSubmitting flag...');
      if (mounted) {
        setState(() => _isSubmitting = false);
        print('✅ Flag reset');
      }
    }
  }

// ------------------- UI --------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const SizedBox(height: 100),

          // 🖼️ Watermark illustration
          Positioned(
            top: 0,
            right: -10,
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/images/cyclist.png',
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView( // عشان لو التلفون صغير يقدر ينزل لتحت 
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 150),

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
                      validator: (v) { // check if the name is null 
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
                      validator: (v) { // check if it null , @ , . 
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Email is required';
                        if (!s.contains('@') || !s.contains('.')) {
                          return 'Enter a valid email';
                        }
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
                            _obscure
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.textDark.withOpacity(.7),
                          ),
                        ),
                      ),
                      validator: (v) { // check if is null , less that 6 
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Password is required';
                        if (s.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => signUp(), // if the user press enter after pass inout -> call the sign up method 
                    ),

                    const SizedBox(height: 36),

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : signUp, // on pressed -> call sign up method 
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
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
                                ..onTap = () => Navigator.pushNamed( // push the login page on top of the sign up - the user can go back 
                                      context,
                                      '/login',
                                    ),
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