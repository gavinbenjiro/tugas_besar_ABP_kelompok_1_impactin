import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Sesuaikan path import ini jika ada error (biasanya otomatis dari GetX)
import '../../../routes/app_pages.dart';
import '../controllers/onboarding_controller.dart';

// 1. Buat class model untuk data konten Onboarding
class OnboardingContent {
  final String image;
  final String smallTitle;
  final String bigTitle;
  final String description;

  OnboardingContent({
    required this.image,
    required this.smallTitle,
    required this.bigTitle,
    required this.description,
  });
}

class OnboardingView extends GetView<OnboardingController> {
  OnboardingView({super.key});

  // 2. Controller untuk PageView dan State untuk melacak index halaman aktif
  final PageController _pageController = PageController();
  final RxInt _currentIndex = 0.obs;

  // 3. Siapkan list konten dengan gambar dan teks yang berbeda-beda
  // Pastikan gambar-gambar ini sudah didaftarkan di pubspec.yaml
  final List<OnboardingContent> _contents = [
    OnboardingContent(
      image: 'assets/images/onb1_bg.png', 
      smallTitle: 'Get Ready',
      bigTitle: 'New Adventures',
      description: 'If you like to travel, then this is  for you! Here you can explore the beauty of the world.',
    ),
    OnboardingContent(
      image: 'assets/images/onb2_bg.png', // Ganti dengan nama file gambarmu
      smallTitle: 'Share your',
      bigTitle: 'Knowledge',
      description: 'Leave a footprint of kindness wherever you go. Join us in making quality education accessible to everyone',
    ),
    OnboardingContent(
      image: 'assets/images/onb3_bg.png', // Ganti dengan nama file gambarmu
      smallTitle: 'Answering the Call',
      bigTitle: 'of Humanity',
      description: 'Every second counts, and your presence could make all the difference.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BAGIAN CAROUSEL (Gambar & Teks)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              // Update state saat halaman digeser
              _currentIndex.value = index;
            },
            itemCount: _contents.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // BACKGROUND IMAGE
                  Image.asset(
                    _contents[index].image,
                    fit: BoxFit.cover,
                  ),

                  // DARK OVERLAY (Agar teks lebih mudah dibaca)
                  Container(
                    color: Colors.black.withOpacity(0.35),
                  ),

                  // TEXT CONTENT
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end, // Dorong teks ke bawah
                        children: [
                          // SMALL TITLE
                          Text(
                            _contents[index].smallTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // BIG TITLE
                          Text(
                            _contents[index].bigTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // DESCRIPTION
                          Text(
                            _contents[index].description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          
                          // Memberikan jarak kosong untuk indikator dan tombol di bawahnya
                          const SizedBox(height: 130), 
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // BAGIAN BAWAH (Indikator & Tombol) - Posisi Tetap (Fixed)
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Obx(
              () => Column(
                children: [
                  // PAGE INDICATOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => _buildDot(isActive: index == _currentIndex.value),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logika Tombol: 
                        // Jika di halaman terakhir -> Ke halaman Login
                        // Jika tidak -> Geser ke halaman selanjutnya
                        if (_currentIndex.value == _contents.length - 1) {
                          Get.offAllNamed(Routes.LOGIN);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005F56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text(
                        // Teks tombol berubah otomatis di halaman terakhir
                        _currentIndex.value == _contents.length - 1
                            ? "Mulai Sekarang"
                            : "Selanjutnya",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat titik indikator (dots)
  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8, // Titik aktif akan lebih panjang
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}