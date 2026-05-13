import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class UploadAudioController extends GetxController {
  Interpreter? _interpreter;
  List<String> _labels = [];

  final selectedFileName = "No file selected".obs;
  final predictedLabel = "Select a WAV file".obs;
  final confidence = 0.0.obs;

  static const int _expectedInputSize = 44032;

  @override
  void onInit() {
    super.onInit();
    _loadModelAndLabels();
  }

  @override
  void onClose() {
    _interpreter?.close();
    super.onClose();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = labelData
          .split('\n')
          .where((line) => line.isNotEmpty)
          .map((line) => line.split(' ').sublist(1).join(' '))
          .toList();

      _interpreter = await Interpreter.fromAsset(
        'assets/ml/soundclassifier_with_metadata.tflite',
      );
    } catch (e) {
      predictedLabel.value = "Failed to load model: $e";
    }
  }

  Future<void> pickAndClassifyFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.isNotEmpty) {
        String? path = result.files.first.path;
        if (path != null) {
          selectedFileName.value = result.files.first.name;
          predictedLabel.value = "Processing...";
          confidence.value = 0.0;

          File file = File(path);
          Uint8List bytes = await file.readAsBytes();

          int headerSize = 44; // WAV header
          if (bytes.length <= headerSize) {
            predictedLabel.value = "Invalid audio file";
            return;
          }

          Uint8List audioData = bytes.sublist(headerSize);
          Int16List int16Data = audioData.buffer.asInt16List(
            audioData.offsetInBytes,
            audioData.lengthInBytes ~/ 2,
          );

          List<int> samplesToProcess = [];
          if (int16Data.length >= _expectedInputSize) {
            samplesToProcess = int16Data.sublist(0, _expectedInputSize);
          } else {
            samplesToProcess = int16Data.toList();
            while (samplesToProcess.length < _expectedInputSize) {
              samplesToProcess.add(0);
            }
          }

          _runInference(samplesToProcess);
        }
      }
    } catch (e) {
      predictedLabel.value = "Error picking file: $e";
    }
  }

  void _runInference(List<int> pcmData) {
    if (_interpreter == null || _labels.isEmpty) return;

    try {
      // 1. CEK KEMAUAN MODEL (INPUT & OUTPUT SHAPE)
      var inputShape = _interpreter!.getInputTensor(0).shape;
      var outputShape = _interpreter!.getOutputTensor(0).shape;

      print("🔥 Model butuh INPUT shape: $inputShape");
      print("🔥 Model butuh OUTPUT shape: $outputShape");

      // 2. SIAPKAN DATA INPUT (Ubah ke Float32List)
      Float32List inputData = Float32List(pcmData.length);
      for (int i = 0; i < pcmData.length; i++) {
        inputData[i] = pcmData[i] / 32768.0;
      }

      // 3. SESUAIKAN DIMENSI INPUT
      Object input;
      if (inputShape.length == 1) {
        // Jika model minta [15600] (1 Dimensi)
        input = inputData;
      } else {
        // Jika model minta [1, 15600] (2 Dimensi)
        input = [inputData];
      }

      // 4. SESUAIKAN DIMENSI OUTPUT
      Object output;
      if (outputShape.length == 1) {
        // Jika model minta [3] (1 Dimensi)
        output = List.filled(_labels.length, 0.0);
      } else {
        // Jika model minta [1, 3] (2 Dimensi)
        // Note: Kita gunakan List.generate agar tidak reference memory yang sama
        output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
      }

      // 5. JALANKAN INFERENCE
      _interpreter!.run(input, output);

      // 6. AMBIL HASILNYA
      List<double> probabilities;
      if (outputShape.length == 1) {
        probabilities = output as List<double>;
      } else {
        probabilities = (output as List<List<double>>)[0];
      }

      // 7. CARI PROBABILITAS TERTINGGI
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
        print("✅ Berhasil! Hasil: ${_labels[maxIndex]} ($maxProb)");
      }
    } catch (e) {
      predictedLabel.value = "Inference error";
      print("🔥 Error detail: $e");
    }
  }
}
