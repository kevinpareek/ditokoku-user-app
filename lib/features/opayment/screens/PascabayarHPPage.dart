import 'package:flutter/material.dart';
import 'PascabayarTopUpPage.dart';

class PascabayarHPPage extends StatefulWidget {
  const PascabayarHPPage({super.key});

  @override
  State<PascabayarHPPage> createState() => _PascabayarHPPageState();
}

class _PascabayarHPPageState extends State<PascabayarHPPage> {
  // Daftar provider HP Pascabayar
  final List<Map<String, dynamic>> hpProviders = [
    {
      'name': 'Kartu Halo',
      'description': 'Bayar tagihan Kartu Halo bulanan',
      'logoPath': 'https://pbs.twimg.com/profile_images/1410496569355378693/A2kPM86S_400x400.jpg',
      'iconColor': Color(0xFFD32F2F),
      'buyerSkuCode': 'postgdrrrz',
    },
    {
      'name': 'Indosat Postpaid',
      'description': 'Bayar tagihan Indosat bulanan',
      'logoPath': 'https://im3-img.indosatooredoo.com/dataprod/portalcontent/portal/images/pagemetaimage/638677123279403092.png',
      'iconColor': Color(0xFFFFB300),
      'buyerSkuCode': 'indosat_pascabayar',
    },
    {
      'name': 'XL Postpaid',
      'description': 'Bayar tagihan XL bulanan',
      'logoPath': 'https://storage.googleapis.com/static-priocms-dev/2021/08/ddasd-3.jpeg',
      'iconColor': Color(0xFF1565C0),
      'buyerSkuCode': 'postdaaaax',
    },
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/image/goback.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pasca Bayar HP',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: hpProviders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildProviderCard(hpProviders[index]);
          },
        ),
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PascabayarTopUpPage(
              serviceName: provider['name'],
              serviceDescription: provider['description'],
              logoPath: provider['logoPath'],
              buyerSkuCode: provider['buyerSkuCode'],
              serviceColor: provider['iconColor'],
              serviceType: 'hp_pascabayar',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo container
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                provider['logoPath'],
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: provider['iconColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.phone,
                      color: provider['iconColor'],
                      size: 24,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          provider['iconColor'],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Provider info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}