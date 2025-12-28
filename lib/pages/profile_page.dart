import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? selectedGender;
  DateTime? dateOfBirth;
  bool isEditing = false;
  final TextEditingController _usernameController = TextEditingController(
    text: "Username",
  );

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontFamily: 'Cinzel', fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFF451B80),
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    enabled: isEditing,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F1654),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Gender",
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                color: Color(0xFF2F1654),
              ),
            ),
            const SizedBox(height: 8),
            _buildDropdown(),
            const SizedBox(height: 20),
            const Text(
              "Date of Birth",
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                color: Color(0xFF2F1654),
              ),
            ),
            const SizedBox(height: 8),
            _buildCalendar(),
            const SizedBox(height: 20),
            const Text(
              "Mood",
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                color: Color(0xFF2F1654),
              ),
            ),
            const SizedBox(height: 8),
            _buildMoodButton(),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => isEditing = !isEditing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF451B80),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                label: Text(
                  isEditing ? "Save" : "Edit Profile",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Achievements",
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F1654),
              ),
            ),
            const SizedBox(height: 20),
            _buildBadgesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return IgnorePointer(
      ignoring: !isEditing,
      child: Opacity(
        opacity: isEditing ? 1 : 0.7,
        child: Container(
          width: 180,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF451B80),
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButton<String>(
            value: selectedGender,
            hint: const Text(
              "Select Gender",
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
            isExpanded: true,
            dropdownColor: const Color(0xFF6A41A1),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: const SizedBox(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
            onChanged: (String? newValue) =>
                setState(() => selectedGender = newValue),
            items: ['Male', 'Female', 'Other']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return GestureDetector(
      onTap: isEditing
          ? () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: dateOfBirth ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF451B80),
                      onPrimary: Colors.white,
                      onSurface: Color(0xFF2F1654),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => dateOfBirth = picked);
            }
          : null,
      child: Container(
        alignment: Alignment.center,
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF451B80),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          dateOfBirth == null
              ? "Calendar"
              : "${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}",
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton() {
    return Container(
      alignment: Alignment.center,
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF451B80),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Based on last story",
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final badges = [
      {'title': 'Bipolar Explorer', 'unlocked': false},
      {'title': 'Anxiety Navigator', 'unlocked': false},
      {'title': 'Isolation Survivor', 'unlocked': false},
      {'title': 'King of Stories', 'unlocked': true},
      {'title': 'Calm Mind', 'unlocked': true},
      {'title': 'Resilient Heart', 'unlocked': false},
      {'title': 'Empathic Soul', 'unlocked': false},
      {'title': 'King of Emotions', 'unlocked': false},
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      childAspectRatio: 0.9,
      children: badges.map((badge) {
        final unlocked = badge['unlocked'] as bool;
        return GestureDetector(
          onTap: () => _showBadgeDialog(badge['title'] as String, unlocked),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? const Color(0xFFF8E9A1)
                          : const Color(0xFF6A41A1),
                      boxShadow: unlocked
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.7),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  if (!unlocked)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: Icon(Icons.lock, color: Colors.white70, size: 14),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                badge['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: unlocked
                      ? const Color(0xFFFFC300)
                      : const Color(0xFF2F1654),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showBadgeDialog(String title, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFFF8E9A1).withOpacity(0.85)
                      : const Color(0xFFC8B7F2).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isUnlocked)
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isUnlocked ? "🏅 Achieved!" : "🔒 Locked",
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF451B80),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isUnlocked
                          ? "You earned the $title badge!\nYou didn’t just tell stories — you *became* one 👑📖"
                          : "This badge is still locked.\nKeep playing and discovering stories to unlock it 💫",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF2F1654),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
