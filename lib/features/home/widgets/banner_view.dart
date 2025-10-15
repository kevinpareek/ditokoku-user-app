import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/util/dimensions.dart';

class BannerView extends StatefulWidget {
  final bool isFeatured;
  const BannerView({super.key, required this.isFeatured});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  int _current = 0;
  Future<List<String>>? _futureBanners; // ✅ nullable & safe

  @override
  void initState() {
    super.initState(); // ✅ wajib duluan
    _futureBanners = fetchFeaturedBanners(); // ✅ assign setelah super
  }

  Future<List<String>> fetchFeaturedBanners() async {
    const apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/featured';
    print('🌐 Fetching banners from $apiUrl');
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final List data = jsonData['data'] ?? [];

        final List<String> banners = data.map<String>((b) {
          final img = b['image']?.toString() ?? '';

          // ✅ Deteksi format Laravel
          final isLaravelPattern =
              RegExp(r'^\d{4}-\d{2}-\d{2}-[a-z0-9]+\.(png|jpg|jpeg|webp)$')
                  .hasMatch(img);

          final url = isLaravelPattern
              ? 'https://dash.ditokoku.id/storage/app/public/banner/$img'
              : 'https://apinew.ditokoku.id/uploads/banners/$img';

          print('🧠 image=$img → isLaravel=$isLaravelPattern → $url');
          return url;
        }).toList();

        print('✅ Loaded ${banners.length} banners');
        return banners;
      } else {
        print('❌ Error response: ${res.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _futureBanners, // ✅ pakai Future yang disimpan
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada banner ditemukan"));
        }

        final banners = snapshot.data!;
        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder: (context, index, realIdx) {
                final imageUrl = banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.grey, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            options: CarouselOptions(
  autoPlay: true,
  enlargeCenterPage: false,
  disableCenter: true,
  viewportFraction: 1,
  autoPlayInterval: const Duration(seconds: 7),
  height: GetPlatform.isDesktop
      ? 400 // Desktop proporsional, bisa 400–450 biar enak dilihat
      : MediaQuery.of(context).size.width / 2.5, // ✅ Rasio 2.5:1 (2500x1000)
  onPageChanged: (index, reason) {
    setState(() {
      _current = index;
    });
  },
),

            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() => _current = entry.key),
                  child: Container(
                    width: 8,
                    height: 8,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
