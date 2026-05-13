import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class RealtimeAudioController extends GetxController {
  final _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  Interpreter? _interpreter;
  List<String> _labels = [];

  final isRecording = false.obs;
  final predictedLabel = "Loading...".obs;
  final confidence = 0.0.obs;

  static const int _sampleRate = 16000;
  static const int _expectedInputSize = 15600;
  
  List<int> _audioBuffer = [];

  @override
  void onInit() {
    super.onInit();
    _loadModelAndLabels();
  }

  @override
  void onClose() {
    _stopRecording();
    _audioRecorder.dispose();
    _interpreter?.close();
    super.onClose();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = labelData.split('\n').where((line) => line.isNotEmpty)
          .map((line) => line.split(' ').sublist(1).join(' ')).toList();

      _interpreter = await Interpreter.fromAsset('assets/ml/soundclassifier_with_metadata.tflite');
      predictedLabel.value = "Ready to record";
    } catch (e) {
      predictedLabel.value = "Failed to load model";
    }
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        predictedLabel.value = "Microphone permission denied";
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        final stream = await _audioRecorder.startStream(const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ));

        _audioBuffer.clear();
        isRecording.value = true;
        predictedLabel.value = "Listening...";

        _audioStreamSubscription = stream.listen((Uint8List data) {
          _processAudioData(data);
        });
      }
    } catch (e) {
      predictedLabel.value = "Error starting record: $e";
    }
  }

  Future<void> _stopRecording() async {
    await _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;
    await _audioRecorder.stop();
    isRecording.value = false;
    predictedLabel.value = "Ready to record";
    confidence.value = 0.0;
  }

  void _processAudioData(Uint8List data) {
    Int16List int16Data = data.buffer.asInt16List(data.offsetInBytes, data.lengthInBytes ~/ 2);
    _audioBuffer.addAll(int16Data);

    if (_audioBuffer.length >= _expectedInputSize) {
      List<int> samplesToProcess = _audioBuffer.sublist(_audioBuffer.length - _expectedInputSize);
      _audioBuffer = _audioBuffer.sublist(_audioBuffer.length - (_expectedInputSize ~/ 2));
      _runInference(samplesToProcess);
    }
  }

  void _runInference(List<int> pcmData) {
    if (_interpreter == null || _labels.isEmpty) return;

    List<double> inputData = pcmData.map((e) => e / 32768.0).toList();
    var input = [inputData];
    var output = List.filled(1, List.filled(_labels.length, 0.0));

    try {
      _interpreter!.run(input, output);
      List<double> probabilities = output[0];
      
      double maxProb = 0.0;
      int maxIndex = -1;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1) {
        predictedLabel.value = _labels[maxIndex];
        confidence.value = maxProb;
      }
    } catch (e) {}
  }
}
