import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicaredriver/src/presentation/controller/homecontroller/Homecontroller.dart';

class RecTile extends StatelessWidget {
  final int index;

  const RecTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final homectrl = Get.find<Homecontroller>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 37,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final url = homectrl.audioList[index];
                      homectrl.playAudioAtIndex(index, url);
                    },
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: Obx(() {
                        final isThisPlaying =
                            homectrl.currentplayingIndex.value == index &&
                            homectrl.isPlaying.value;
                        return Icon(
                          isThisPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() {
                      final isThisPlaying =
                          homectrl.currentplayingIndex.value == index;
                      final current = isThisPlaying
                          ? homectrl.currentPosition.value.inSeconds.toDouble()
                          : 0;
                      final total = isThisPlaying
                          ? homectrl.totalDuration.value.inSeconds.toDouble()
                          : 1;

                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xff353459),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: const Color(0xff353459),
                          overlayColor: const Color(
                            0xff353459,
                          ).withOpacity(0.2),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: current.clamp(0, total.toDouble()).toDouble(),
                          min: 0,
                          max: total.toDouble(),
                          onChanged: (value) {
                            if (isThisPlaying) {
                              homectrl.seekTo(value);
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}
