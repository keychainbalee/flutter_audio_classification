import 'package:audio_project/app/modules/realtime_audio/controllers/realtime_audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RealtimeAudioView extends GetView<RealtimeAudioController> {
  const RealtimeAudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Background senada dengan Home & Upload
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blueGrey[900]),
        title: Text(
          'Realtime Audio',
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER TEXT ---
              Text(
                "Live Microphone",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Deteksi suara secara langsung. Dekatkan sumber suara ke mikrofon perangkatmu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // --- TOMBOL MIC ANIMATIF ---
              Obx(() {
                bool isRec = controller.isRecording.value;
                return GestureDetector(
                  onTap: controller.toggleRecording,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isRec ? 160 : 140, // Membesar sedikit saat merekam
                      height: isRec ? 160 : 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRec ? const Color(0xFFFF512F) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isRec 
                                ? const Color(0xFFFF512F).withOpacity(0.4) 
                                : Colors.black.withOpacity(0.05),
                            blurRadius: isRec ? 30 : 15,
                            spreadRadius: isRec ? 10 : 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: isRec ? Colors.transparent : Colors.grey[200]!,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isRec ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 60,
                        color: isRec ? Colors.white : Colors.blueGrey[300],
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // --- STATUS LABEL ---
              Obx(() => Text(
                controller.isRecording.value 
                    ? "Mendengarkan suara..." 
                    : "Tap ikon mic untuk mulai",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: controller.isRecording.value 
                      ? const Color(0xFFFF512F) 
                      : Colors.blueGrey[400],
                  letterSpacing: 0.5,
                ),
              )),

              const SizedBox(height: 48),

              // --- KARTU HASIL LIVE PREDIKSI ---
              Obx(() {
                // Hanya tampilkan kartu jika sudah ada deteksi
                if (controller.predictedLabel.value == "Ready to record" ||
                    controller.predictedLabel.value == "Listening..." ||
                    controller.confidence.value == 0) {
                  return const SizedBox.shrink();
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Live Result",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        controller.predictedLabel.value.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey[900],
                          letterSpacing: 1,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Confidence",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[600],
                            ),
                          ),
                          Text(
                            "${(controller.confidence.value * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF512F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: controller.confidence.value,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF512F)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}