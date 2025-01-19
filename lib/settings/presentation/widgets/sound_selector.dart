import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';
import 'package:pomodoro_app2/sound/presentation/providers/sound_player_provider.dart';

class SoundSelector extends StatelessWidget {
  final NotificationSound selectedSound;
  final ValueChanged<NotificationSound?> onChanged;

  const SoundSelector({
    super.key,
    required this.selectedSound,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Sound: '),
        DropdownButton<NotificationSound>(
          value: selectedSound,
          items: NotificationSound.values
              .map((sound) => DropdownMenuItem(
                    value: sound,
                    child: Text(sound.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(width: 8),
        Consumer(
          builder: (context, ref, child) {
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                final soundPlayer = ref.read(soundPlayerProvider);
                soundPlayer.playSound(selectedSound);
              },
            );
          },
        ),
      ],
    );
  }
}
