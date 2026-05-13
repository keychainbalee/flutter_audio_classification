import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/realtime_audio_controller.dart';

class RealtimeAudioView extends GetView<RealtimeAudioController> {
  const RealtimeAudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Audio Classification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Icon(controller.isRecording.value ? Icons.mic : Icons.mic_none, size: 100, color: controller.isRecording.value ? Colors.red : Colors.grey)),
              const SizedBox(height: 32),
              Obx(() => Text(controller.predictedLabel.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),
              Obx(() => controller.confidence.value > 0
                  ? Column(
                      children: [
                        Text('Confidence: ${(controller.confidence.value * 100).toStringAsFixed(1)}%'),
                        LinearProgressIndicator(value: controller.confidence.value, color: Colors.deepPurple),
                      ],
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 48),
              Obx(() => ElevatedButton.icon(
                onPressed: controller.toggleRecording,
                icon: Icon(controller.isRecording.value ? Icons.stop : Icons.play_arrow),
                label: Text(controller.isRecording.value ? 'Stop Recording' : 'Start Recording'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
