import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import 'definition_page.dart';

class StorySelectionPage extends StatelessWidget {
  const StorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Choose a Story',
          style: TextStyle(fontFamily: 'Cinzel'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _storyBtn(context, title: 'The Room of Echoes', topic: 'Anxiety'),
              const SizedBox(height: 16),
              _storyBtn(
                context,
                title: 'A Walk Through Yesterday',
                topic: 'Depression',
              ),
              const SizedBox(height: 16),
              _storyBtn(context, title: 'Quiet Streets', topic: 'Loneliness'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storyBtn(
    BuildContext context, {
    required String title,
    required String topic,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF451B80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DefinitionPage(storyTitle: title, topic: topic),
            ),
          );
        },
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
