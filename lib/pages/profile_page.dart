import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/achievement_model.dart';
import '../models/story_progress.dart';
import '../models/user_session.dart';
import '../services/auth_service.dart';
import '../services/achievement_service.dart';
import '../services/story_progress_service.dart';
import '../utils/app_strings.dart';
import '../widgets/localized_text.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_popup.dart';
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

  final AuthService _authService = AuthService();
  final StoryProgressService _progressService = StoryProgressService();
  final AchievementService _achievementService = AchievementService();
  final ImagePicker _imagePicker = ImagePicker();

  StoryProgressData _storyStats = const StoryProgressData();
  AchievementState _achievementState = AchievementState.empty();
  List<AchievementModel> _achievements = const [];
  String? _avatarUrl;

  final TextEditingController _usernameController = TextEditingController(
    text: "Username",
  );

  UserProfile? get _user => UserSession.currentUser;

  @override
  void initState() {
    super.initState();
    final user = _user;
    if (user != null) {
      _usernameController.text = user.name;
      selectedGender = user.gender == 'Not set' ? null : user.gender;
      dateOfBirth = user.dateOfBirth;
      _avatarUrl = user.avatarUrl;
    }
    _initializeProfileData();
  }

  Future<void> _initializeProfileData() async {
    await _loadStoryStats();
    await _refreshAchievements();
  }

  Future<void> _loadStoryStats() async {
    final data = await _progressService.load();
    if (!mounted) return;

    setState(() {
      _storyStats = data;
    });
  }

  Future<void> _refreshAchievements() async {
    final storyState = await _achievementService.loadState();

    if (!mounted) return;

    setState(() {
      _achievementState = storyState;
      _achievements = _achievementService.buildAchievementModels(storyState);
    });
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _glass(
                radius: 26,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t(context, 'username'), style: _labelStyle),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _usernameController,
                            enabled: isEditing,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: t(context, 'enter_name'),
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
                          const SizedBox(height: 4),
                          LocalizedText(
                            "Story explorer finding calm one choice at a time.",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _labelStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _glassPill(
                      height: 44,
                      onTap: _handleEditTap,
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
                            isEditing ? t(context, 'save') : t(context, 'edit'),
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
                    Text(t(context, 'details'), style: _titleStyle),
                    const SizedBox(height: 12),

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
                              Text(t(context, 'gender'), style: _labelStyle),
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
                              Text(t(context, 'date_of_birth'), style: _labelStyle),
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
                          Icons.email_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t(context, 'email'), style: _labelStyle),
                              const SizedBox(height: 6),
                              Text(
                                _user?.email ?? t(context, 'not_available'),
                                style: _valueStyle,
                              ),
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
                              Text(t(context, 'mood'), style: _labelStyle),
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

              _glass(
                radius: 24,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    _statChip(
                      label: t(context, 'stories_completed'),
                      value: "${_achievementState.stats.storiesCompleted}",
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      label: t(context, 'last_story'),
                      value: _prettyStoryName(_storyStats.lastStoryPlayed),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                t(context, 'achievements'),
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 6),
              LocalizedText(
                "Unlocked through your journey in Storium.",
                style: _labelStyle,
              ),
              const SizedBox(height: 12),

              _buildAchievementsSections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _labelStyle,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _valueStyle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEditTap() async {
    if (isEditing) {
      final existing = _user;
      if (existing != null) {
        final updated = existing.copyWith(
          name: _usernameController.text.trim().isEmpty
              ? existing.name
              : _usernameController.text.trim(),
          gender: selectedGender ?? existing.gender,
          dateOfBirth: dateOfBirth,
        );
        try {
          UserSession.currentUser = updated;
          await UserSession.saveCurrentUser();

          await _authService.saveProfile(
            UserSession.currentUser!,
            idToken: UserSession.currentUser!.idToken,
          );
        } on AuthServiceException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved on this device only. ${e.message}'),
            ),
          );
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Saved on this device only. Could not sync profile right now.',
              ),
            ),
          );
        }
      }
    }

    if (!mounted) return;
    setState(() => isEditing = !isEditing);
  }

  Widget _buildAvatar() {
    final avatar = _avatarImage();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          ),
          child: ClipOval(child: avatar),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: InkWell(
            onTap: _showAvatarOptions,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarImage() {
    final avatarUrl = _avatarUrl;

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const Icon(Icons.person_rounded, color: Colors.white, size: 42);
    }

    if (avatarUrl.startsWith('data:image/')) {
      final bytes = _bytesFromDataUrl(avatarUrl);
      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover);
      }
    }

    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.person_rounded, color: Colors.white, size: 42),
    );
  }

  Future<void> _showAvatarOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF2A2140),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                  ),
                  title: Text(
                    t(context, 'choose_from_device'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAvatarFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                  ),
                  title: Text(
                    t(context, 'use_default_avatar'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _setDefaultAvatar();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatarFromGallery() async {
    final xFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 900,
    );

    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    final mime = xFile.mimeType ?? 'image/jpeg';
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';

    await _saveAvatar(dataUrl);
  }

  Future<void> _setDefaultAvatar() async {
    await _saveAvatar('');
  }

  Future<void> _saveAvatar(String avatarUrl) async {
    final existing = _user;
    if (existing == null) return;

    final updated = avatarUrl.isEmpty
        ? existing.copyWith(avatarUrl: null)
        : existing.copyWith(avatarUrl: avatarUrl);

    UserSession.currentUser = updated;
    await UserSession.saveCurrentUser();
    try {
      await _authService.saveProfile(updated, idToken: updated.idToken);
    } on AuthServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avatar saved on this device only. ${e.message}'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Avatar saved on this device only. Could not sync right now.',
          ),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _avatarUrl = updated.avatarUrl;
    });
  }

  Uint8List? _bytesFromDataUrl(String dataUrl) {
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex < 0 || commaIndex >= dataUrl.length - 1) return null;

    final base64Part = dataUrl.substring(commaIndex + 1);

    try {
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
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
                t(context, 'select_gender'),
                style: _valueStyle.copyWith(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: _valueStyle,
              onChanged: (String? newValue) {
                setState(() => selectedGender = newValue);
              },
              items: ['Male', 'Female', 'Other']
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'Male'
                            ? t(context, 'male')
                            : value == 'Female'
                                ? t(context, 'female')
                                : t(context, 'other'),
                        style: _valueStyle,
                      ),
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
      text = t(context, 'pick_a_date');
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
                  DateTime tempDate = dateOfBirth ?? DateTime(2000);
                  final didSave = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      final theme = Theme.of(dialogContext).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF451B80),
                          onPrimary: Colors.white,
                          onSurface: Color(0xFF2F1654),
                        ),
                      );
                      return Theme(
                        data: theme,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            tRead(context, 'date_of_birth'),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                          content: SizedBox(
                            width: 320,
                            child: CalendarDatePicker(
                              initialDate: tempDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              onDateChanged: (picked) {
                                tempDate = picked;
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: Text(tRead(context, 'cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Text(tRead(context, 'save')),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (didSave == true && mounted) {
                    setState(() => dateOfBirth = tempDate);
                  }
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
    final int calmScore = _storyStats.lastStoryCalm;
    final int anxietyScore = _storyStats.lastStoryAnxiety;

    final String moodLabel;
    final String moodEmoji;

    if (calmScore == 0 && anxietyScore == 0) {
      moodLabel = t(context, 'based_on_last_story');
      moodEmoji = "😐";
    } else if (calmScore >= anxietyScore) {
      moodLabel = t(context, 'calm');
      moodEmoji = "🙂";
    } else {
      moodLabel = t(context, 'anxious');
      moodEmoji = "😟";
    }

    return _glassPill(
      height: 46,
      child: Row(
        children: [
          Expanded(
            child: Text(
              moodLabel,
              style: _valueStyle.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(moodEmoji, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildAchievementsSections() {
    final items = _achievements;

    if (items.isEmpty) {
      return _glass(
        radius: 20,
        child: Center(child: Text(t(context, 'no_achievements_yet'), style: _labelStyle)),
      );
    }
    final grouped = <AchievementSection, List<AchievementModel>>{
      for (final section in AchievementSection.values) section: <AchievementModel>[],
    };
    for (final item in items) {
      grouped[item.section]!.add(item);
    }
    final sectionOrder = AchievementSection.values;
    return Column(
      children: [
        for (final section in sectionOrder) ...[
          if (grouped[section]!.isNotEmpty) _buildSectionTitle(section),
          if (grouped[section]!.isNotEmpty) const SizedBox(height: 10),
          if (grouped[section]!.isNotEmpty)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.92,
              children: grouped[section]!
                  .map(
                    (achievement) => AchievementCard(
                      achievement: achievement,
                      onTap: () => _showBadgeDialog(achievement),
                    ),
                  )
                  .toList(),
            ),
          if (section != sectionOrder.last && grouped[section]!.isNotEmpty)
            const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(AchievementSection section) {
    String label;
    switch (section) {
      case AchievementSection.stories:
        label = 'Stories';
        break;
      case AchievementSection.emotions:
        label = 'Emotions';
        break;
      case AchievementSection.garden:
        label = 'Garden';
        break;
      case AchievementSection.activity:
        label = 'Activity';
        break;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: LocalizedText(
        label,
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.92),
        ),
      ),
    );
  }

  void _showBadgeDialog(AchievementModel achievement) {
    if (!achievement.unlocked) {
      showAchievementPopup(
        context,
        achievement.title,
        achievement.hint,
        icon: Icons.lock_rounded,
      );
      return;
    }
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
                    Icon(
                      achievement.icon,
                      size: 36,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      achievement.unlocked ? "🏅 ${t(context, 'achieved')}" : "🔒 ${t(context, 'locked')}",
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LocalizedText(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LocalizedText(
                      achievement.description,
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

  String _prettyStoryName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return t(context, 'none');

    switch (raw.toLowerCase()) {
      case 'depression':
        return 'What Still Remains';
      case 'loneliness':
        return 'Alone, Again';
      case 'grief':
        return 'The Space You Left';
      default:
        return raw;
    }
  }
}
