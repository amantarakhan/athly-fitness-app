// ignore: file_names
import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:athlynew/AppShell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GoalPreferences { // data model that represents one completed onboarding result. - one user profile 
  final String goal;          // Build Muscle, Lose Weight, Improve Stamina, Maintain Fitness
  final String frequency;     // 3 times a week, 5 times a week, Every day
  final String timeOfDay;     // Morning, Afternoon, Evening
  final String level;         // Beginner, Intermediate, Advanced

// a constructor - requires all fields 
  const GoalPreferences({
    required this.goal,
    required this.frequency,
    required this.timeOfDay,
    required this.level,
  });

// cuz i need to store them in FireStore and its onlu accept maps not objects 
// convert dart objects to Firestore Format 
  Map<String, dynamic> toJson() => {
        'goal': goal,
        'frequency': frequency,
        'timeOfDay': timeOfDay,
        'level': level,
      };
}

class GoalSettingScreen extends StatefulWidget { // statefull cuz i want the button to change when the user tap it 
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  //STATE VARIABLES - stores the answer chhosen by the user 
  String? _goal;
  String? _frequency;
  String? _timeOfDay;
  String? _level;
  bool _isSaving = false;

// a lists of all the answers for the 4 questions 
  final _goals = const [
    'Build Muscle',
    'Lose Weight',
    'Improve Stamina',
    'Maintain Fitness',
  ];
  final _frequencies = const [
    '3 times a week',
    '5 times a week',
    'Every day',
  ];
  final _times = const ['Morning', 'Afternoon', 'Evening'];
  final _levels = const ['Beginner', 'Intermediate', 'Advanced'];

  int get _answeredCount => [ // collects all answers 
        _goal,
        _frequency,
        _timeOfDay,
        _level,
      ].where((e) => e != null).length;

// this return T only when all answers are not null 
  bool get _canSave =>
      _goal != null && _frequency != null && _timeOfDay != null && _level != null;

// ---------CORE LOGIC ------------------
  Future<void> _save() async {
    if (!_canSave) { // not all the questions are answerd  
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

// duplicate taps - exist 
    if (_isSaving) return;
    // buton displayed - loading begin 
    setState(() => _isSaving = true);
    print('\n🟦🟦🟦 SAVING GOAL PREFERENCES 🟦🟦🟦');

    try {
      // create a GoalPreferences object that has the value of this user 
      final prefs = GoalPreferences(
        goal: _goal!,
        frequency: _frequency!,
        timeOfDay: _timeOfDay!,
        level: _level!,
      );

      print('📝 Goal: ${prefs.goal}');
      print('📝 Frequency: ${prefs.frequency}');
      print('📝 Time of Day: ${prefs.timeOfDay}');
      print('📝 Level: ${prefs.level}');

      // Save to Firestore if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) { // where to save data - the correct user ID 
        print('🔵 Saving preferences to Firestore for user: ${user.uid}');
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(prefs.toJson(), SetOptions(merge: true));
        
        print('✅ Preferences saved to Firestore!');
      } else {
        print('⚠️ No user logged in, preferences not saved to Firestore');
      }

      // Preload heavy images before navigations 
      print('🔵 Preloading images...');
      await precacheImage(const AssetImage('assets/images/treadmill.png'), context);
      print('✅ Images preloaded!');

      if (!mounted) { // prevents crashes 
        print('⚠️ Widget not mounted, cannot navigate');
        return;
      }
// navigate to the main app (AppShell) 
      print('🔵 Navigating to AppShell...');
      Navigator.of(context).pushAndRemoveUntil( // no going back 
        MaterialPageRoute(builder: (context) => AppShell(prefs: prefs)),
        (route) => false,
      );
      print('✅ Navigation completed!');
      print('🟩🟩🟩 GOAL SETTING COMPLETED 🟩🟩🟩\n');

    } catch (e, stackTrace) { // if any exception happen 
      print('\n❌❌❌ ERROR SAVING PREFERENCES ❌❌❌');
      print('Error: $e');
      print('StackTrace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save preferences: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally { // alawyas runs 
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
// ----------------- UI ---------------------
  @override
  Widget build(BuildContext context) {
    final progress = _answeredCount / 4.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ❌ no back/close button
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Set Your Goal',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.black12.withOpacity(.06),
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuestionCard(
                      title: "What's your main fitness goal?",
                      subtitle: "Pick the one that fits you best.",
                      options: _goals,
                      selected: _goal,
                      onSelect: (v) => setState(() => _goal = v),
                    ),
                    const SizedBox(height: 16),
                    _QuestionCard(
                      title: "How often do you plan to work out?",
                      subtitle: "Consistency matters!",
                      options: _frequencies,
                      selected: _frequency,
                      onSelect: (v) => setState(() => _frequency = v),
                    ),
                    const SizedBox(height: 16),
                    _QuestionCard(
                      title: "When do you prefer to work out?",
                      subtitle: "We'll suggest times that fit your day.",
                      options: _times,
                      selected: _timeOfDay,
                      onSelect: (v) => setState(() => _timeOfDay = v),
                    ),
                    const SizedBox(height: 16),
                    _QuestionCard(
                      title: "What's your current fitness level?",
                      subtitle: "So we tailor the intensity properly.",
                      options: _levels,
                      selected: _level,
                      onSelect: (v) => setState(() => _level = v),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // bottom button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_canSave && !_isSaving) ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save & Continue',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
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

// ---------- UI helper ---------------- 


class _QuestionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _QuestionCard({
    required this.title,
    this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  // have Question title , subtitile , options 
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.black12.withOpacity(.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((o) {
              final isSel = o == selected;
              return ChoiceChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    o,
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
                selected: isSel,
                onSelected: (_) => onSelect(o),
                backgroundColor: const Color(0xFFF6F6F6),
                selectedColor: AppColors.primary.withOpacity(.16),
                labelStyle: TextStyle(
                  color: isSel ? AppColors.navy : Colors.black87,
                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSel
                        ? AppColors.primary.withOpacity(.7)
                        : Colors.black12.withOpacity(.18),
                    width: 1.2,
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}