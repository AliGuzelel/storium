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

  Widget _glass({
    required Widget child,
    double radius = 22,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassPill({
    required Widget child,
    VoidCallback? onTap,
    double height = 48,
  }) {
    final pill = ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return pill;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: pill,
    );
  }

  TextStyle get _titleStyle => TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white.withOpacity(0.92),
  );

  TextStyle get _labelStyle => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    color: Colors.white.withOpacity(0.70),
  );

  TextStyle get _valueStyle => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white.withOpacity(0.92),
  );

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontFamily: 'Cinzel', fontSize: 24),
        ),
        backgroundColor: Colors.white.withOpacity(0.04),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== HEADER CARD =====================
              _glass(
                radius: 26,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Username", style: _labelStyle),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _usernameController,
                            enabled: isEditing,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "Enter name",
                              hintStyle: _valueStyle.copyWith(
                                color: Colors.white.withOpacity(0.45),
                                fontWeight: FontWeight.w500,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _glassPill(
                      height: 44,
                      onTap: () => setState(() => isEditing = !isEditing),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEditing
                                ? Icons.check_rounded
                                : Icons.edit_rounded,
                            color: Colors.white.withOpacity(0.95),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? "Save" : "Edit",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _glass(
                radius: 26,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Details", style: _titleStyle),
                    const SizedBox(height: 12),

                    // Gender row
                    Row(
                      children: [
                        Icon(
                          Icons.wc_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Gender", style: _labelStyle),
                              const SizedBox(height: 6),
                              _buildGenderDropdown(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.cake_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Date of Birth", style: _labelStyle),
                              const SizedBox(height: 6),
                              _buildCalendar(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Icon(
                          Icons.emoji_emotions_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mood", style: _labelStyle),
                              const SizedBox(height: 6),
                              _buildMoodChip(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Achievements",
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 12),
              _buildBadgesGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return IgnorePointer(
      ignoring: !isEditing,
      child: Opacity(
        opacity: isEditing ? 1 : 0.78,
        child: _glassPill(
          height: 46,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2140),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.white.withOpacity(0.9),
              ),
              hint: Text(
                "Select gender",
                style: _valueStyle.copyWith(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: _valueStyle,
              onChanged: (String? newValue) =>
                  setState(() => selectedGender = newValue),
              items: ['Male', 'Female', 'Other']
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: _valueStyle),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    String text;
    if (dateOfBirth == null) {
      text = "Pick a date";
    } else {
      text = "${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}";
    }

    return IgnorePointer(
      ignoring: !isEditing,
      child: Opacity(
        opacity: isEditing ? 1 : 0.78,
        child: _glassPill(
          height: 46,
          onTap: !isEditing
              ? null
              : () async {
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
                },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: dateOfBirth == null
                      ? _valueStyle.copyWith(
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        )
                      : _valueStyle,
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChip() {
    return _glassPill(
      height: 46,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Based on last story",
              style: _valueStyle.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text("😐", style: const TextStyle(fontSize: 18)),
        ],
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
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      childAspectRatio: 0.92,
      children: badges.map((badge) {
        final unlocked = badge['unlocked'] as bool;

        return GestureDetector(
          onTap: () => _showBadgeDialog(badge['title'] as String, unlocked),
          child: _glass(
            radius: 20,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: unlocked
                            ? Colors.white.withOpacity(0.20)
                            : Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: unlocked
                              ? Colors.white.withOpacity(0.35)
                              : Colors.white.withOpacity(0.22),
                          width: 1,
                        ),
                        boxShadow: unlocked
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.22),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: unlocked
                            ? Colors.white.withOpacity(0.95)
                            : Colors.white.withOpacity(0.70),
                        size: 30,
                      ),
                    ),
                    if (!unlocked)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.white.withOpacity(0.75),
                          size: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  badge['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    height: 1.15,
                    color: Colors.white.withOpacity(unlocked ? 0.92 : 0.78),
                    fontWeight: unlocked ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
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
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isUnlocked ? "🏅 Achieved!" : "🔒 Locked",
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isUnlocked
                          ? "You earned the $title badge!\nYou didn’t just tell stories — you *became* one 👑📖"
                          : "This badge is still locked.\nKeep playing and discovering stories to unlock it 💫",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.35,
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
