import 'package:athlynew/goalSetting.dart';
import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'login.dart';
import 'tabs/home.dart';
import 'signUp.dart';
import 'PassReset.dart';
import 'AppShell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp() ;
  runApp(const AthlyApp());

}

class AthlyApp extends StatelessWidget {
  const AthlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",   // global font

      ),
      home: const WelcomeScreen(),
     routes: {
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const SignUpScreen(),
  '/reset': (context) => const ResetPasswordScreen(),
  '/home': (context) => const HomeScreen(),
  '/goal': (context) => const GoalSettingScreen(),
  '/app': (context) => const AppShell(),
  '/welcome': (context) => const WelcomeScreen(),
},
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ✅ Title
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child : Align(
                    alignment: Alignment.centerLeft , 
                    child: const Text(
                      "ATHLY",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: "ArchivoBlack",
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),)
                  ),
                  

                  SizedBox(height: 6),

                  // ✅ Subtitle
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Align(
                      alignment: Alignment.centerLeft ,
                      child: const Text(
                        "Unlock your full potential !",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark , 
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ✅ Illustration
                  Image.asset(
                    "assets/images/welcome.png",
                    height: 260,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  // ✅ Get Started button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
onPressed: () => Navigator.pushNamed(context, '/signup'),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1F3C64),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            color:Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✅ Log in button
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                     child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.textDark,
                            width: 2.5, // 🟢 increased border width
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                           Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },

                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                                       ),
                   ),


                  const SizedBox(height: 40),

                   // ✅ Continue as Guest (clickable)
                  GestureDetector(
                    onTap: () {
                      // 👉 Navigate as guest
                     Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);

                    },
                    child: const Text(
                      "Continue as Guest",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary , 
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

    const SizedBox(height: 40),

    // ⚪ Terms and Conditions
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text.rich(
        TextSpan(
          text: "By continuing, you agree to our ",
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
          children: [
            TextSpan(
              text: "Terms & Conditions",
              style: TextStyle(
                color: Colors.orange, // accent color
                fontWeight: FontWeight.w600,
              ),

            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy.",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ),            
                ],
              ),
            ),
          ),
        ),
      );
  }
}
