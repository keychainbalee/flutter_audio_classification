import 'package:audio_project/app/modules/upload_audio/controllers/upload_audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadAudioView extends GetView<UploadAudioController> {
  const UploadAudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Background senada dengan Home
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blueGrey[900]),
        title: Text(
          'Upload Audio',
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
                "Klasifikasi File WAV",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Unggah rekaman audio (.wav) untuk mendeteksi apakah itu suara kucing, tepuk tangan, atau sekadar background sound.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // --- AREA UPLOAD (DROPZONE) ---
              GestureDetector(
                onTap: controller.pickAndClassifyFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF00C6FF).withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C6FF).withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C6FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_rounded,
                          size: 48,
                          color: Color(0xFF00C6FF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Tap untuk Pilih File",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C6FF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            controller.selectedFileName.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey[400],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- KARTU HASIL PREDIKSI ---
              Obx(() {
                // Jika belum ada file yang diproses, tampilkan ilustrasi kosong
                if (controller.predictedLabel.value == "Select a WAV file" ||
                    controller.predictedLabel.value == "Loading...") {
                  return const SizedBox.shrink(); 
                }

                bool isProcessing = controller.predictedLabel.value == "Processing...";
                bool isError = controller.predictedLabel.value.toLowerCase().contains("error") || 
                               controller.predictedLabel.value.toLowerCase().contains("invalid");

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
                      // Status Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isProcessing
                              ? Colors.orange.withOpacity(0.1)
                              : isError
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isProcessing ? "Menganalisa..." : isError ? "Terjadi Kesalahan" : "Hasil Deteksi",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isProcessing
                                ? Colors.orange[800]
                                : isError
                                    ? Colors.red[800]
                                    : Colors.green[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Hasil Label
                      Text(
                        isProcessing ? "Mohon Tunggu" : controller.predictedLabel.value.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey[900],
                          letterSpacing: 1,
                        ),
                      ),
                      
                      // Menampilkan Confidence Bar jika proses selesai dan tidak error
                      if (controller.confidence.value > 0 && !isProcessing && !isError) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Akurasi",
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
                                color: Color(0xFF4A00E0),
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
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
                          ),
                        ),
                      ] else if (isProcessing) ...[
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(color: Color(0xFF00C6FF)),
                      ]
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