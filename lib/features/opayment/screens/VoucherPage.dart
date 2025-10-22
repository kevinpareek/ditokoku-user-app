import 'package:flutter/material.dart';
import 'VoucherTopUpPage.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data untuk produk vouchers
final List<Map<String, dynamic>> voucherProducts = [
  {
    'name': 'Vidio',
    'description': 'Vidio Premier / Platinum Subscription',
    'logoPath': 'https://play-lh.googleusercontent.com/SfWzLXzi9uSRLuy_tnmOrf3h7GFB_zQUcFU6S18l3UzyW1WoF9WqVa-tibyK8_AfXgvPLYMzbUQsRqaYBqCyVQ',
    'isNetwork': false,
  },
  {
    'name': 'WeTV',
    'description': 'WeTV VIP Subscription',
    'logoPath': 'https://adm-befrmium.freemium.id/storage/01JZPZY3XC34PXS64PX8K6A2PF.png',
    'isNetwork': false,
  },
  {
    'name': 'Telkomsel',
    'description': 'Pulsa & Paket Data Telkomsel',
    'logoPath': 'https://bloguna.com/wp-content/uploads/2025/05/Logo-Telkomsel-Format-CDR-EPS-PNG-AI-SVG-PSD.png',
    'isNetwork': true,
  },
  {
    'name': 'Indosat',
    'description': 'Pulsa & Paket Data Indosat Ooredoo',
    'logoPath': 'https://blue.kumparan.com/image/upload/fl_progressive,fl_lossy,c_fill,f_auto,q_auto:best,w_640/v1641309651/zmdi6igeqc8nm4cszywy.jpg',
    'isNetwork': true,
  },
  {
    'name': 'XL',
    'description': 'Pulsa & Paket Data XL Axiata',
    'logoPath': 'https://staticxl.ext.xlaxiata.co.id/s3fs-public/media/images/big-xl-logo.png',
    'isNetwork': true,
  },
  {
    'name': 'Axis',
    'description': 'Pulsa & Paket Data Axis',
    'logoPath': 'https://blue.kumparan.com/image/upload/fl_progressive,fl_lossy,c_fill,f_auto,q_auto:best,w_640/v1634025439/01g9h4qgs0wnxvh4xxg10e3zep.jpg',
    'isNetwork': true,
  },
  {
    'name': 'Smartfren',
    'description': 'Pulsa & Paket Data Smartfren',
    'logoPath': 'https://media.suara.com/pictures/970x544/2019/12/10/14889-logo-smartfren.jpg',
    'isNetwork': true,
  },
  {
    'name': 'Tri',
    'description': 'Pulsa & Paket Data 3 (Tri)',
    'logoPath': 'https://blue.kumparan.com/image/upload/fl_progressive,fl_lossy,c_fill,f_auto,q_auto:best,w_640/v1634025439/01g6q33b49tgzcwkph2px7x4bj.png',
    'isNetwork': true,
  },
  {
    'name': 'By.U',
    'description': 'Pulsa & Paket Data By.U',
    'logoPath': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSfE-tf5zMfSFydyWe0oiQez9WLWObF_RKsA&s',
    'isNetwork': true,
  },
  {
    'name': 'Alfamart',
    'description': 'Voucher Alfamart / Alfagift',
    'logoPath': 'https://logos-world.net/wp-content/uploads/2022/04/Alfamart-Symbol.png',
    'isNetwork': false,
  },
  {
    'name': 'Indomaret',
    'description': 'Voucher Indomaret',
    'logoPath': 'https://i.pinimg.com/564x/f7/16/f9/f716f9ff7f7012064d05ce5fcddd3b66.jpg',
    'isNetwork': false,
  },
  {
    'name': 'Spotify',
    'description': 'Spotify Premium Subscription',
    'logoPath': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Spotify_logo_without_text.svg/512px-Spotify_logo_without_text.svg.png',
    'isNetwork': false,
  },
  {
    'name': 'Point Blank',
    'description': 'Voucher Point Blank',
    'logoPath': 'https://play-lh.googleusercontent.com/IGOlY-TMU0cGW_I8EFKBkLACxPLu1TQqbqaqx7NUsGMyjNWIO1NdhwdBrq-71pUAHw',
    'isNetwork': false,
  },
  {
    'name': 'Grab',
    'description': 'Grab Voucher & Credits',
    'logoPath': 'https://images.icon-icons.com/2699/PNG/512/grab_logo_icon_169071.png',
    'isNetwork': false,
  },
  {
    'name': 'Kopi Kenangan',
    'description': 'Voucher Kopi Kenangan',
    'logoPath': 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgBLptG_uWleSX8zc6VdaRVZ98de2lJLs0UnhEPT_FRbk7dGjkX55WE2I7TIwFwVBXc4Yc9fqNhxxoNgUdqXI09eGrPirz7qHORCmMASm4Mi8A-OhFP8WLot0wUwUy1YcEtn1vcNEc5USHRfrY8e7aTofqF5_7xseDYGRvYJoLkGhv4m88Ca8sdWMvBJw/s619/simbol-kopi-kenangan.png',
    'isNetwork': false,
  },
  {
    'name': 'Vision+',
    'description': 'Vision+ Premium Subscription',
    'logoPath': 'https://assets.telkomsel.com/public/thumbnails-video/images/2025-10/bg_0.jpg?VersionId=rku_mGQc73VKOxEKChZ4EEifMEuYx7Kx',
    'isNetwork': false,
  },
  {
    'name': 'e-Materai',
    'description': 'Meterai Elektronik 10000',
    'logoPath': 'https://scm.e-meterai.co.id/static/images/logo-main.png',
    'isNetwork': false,
  },
];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return voucherProducts;
    }
    return voucherProducts.where((product) {
      final name = product['name'].toString().toLowerCase();
      final description = product['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

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
          'Vouchers',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari voucher atau pulsa...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Voucher tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.separated(
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildVoucherCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherTopUpPage(
              voucherName: product['name'],
              voucherDescription: product['description'],
              logoPath: product['logoPath'],
              voucherId: _getVoucherId(product['name']),
              isNetwork: product['isNetwork'] ?? false,
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
                product['logoPath'],
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      product['isNetwork'] == true
                          ? Icons.sim_card
                          : Icons.card_giftcard,
                      color: Colors.grey[400],
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
                          Colors.grey[400]!,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
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

  String _getVoucherId(String voucherName) {
    final voucherIdMap = {
      'Vidio': 'vidio',
      'WeTV': 'wetv',
      'Telkomsel': 'telkomsel',
      'Indosat': 'indosat',
      'XL': 'xl',
      'Axis': 'axis',
      'Smartfren': 'smartfren',
      'Tri': 'tri',
      'By.U': 'byu',
      'Alfamart': 'alfamart',
      'Indomaret': 'indomaret',
      'Spotify': 'spotify',
      'Point Blank': 'pointblank',
      'Grab': 'grab',
      'Kopi Kenangan': 'kopikenangan',
      'Vision+': 'visionplus',
      'e-Materai': 'ematerai',
    };
    
    return voucherIdMap[voucherName] ?? voucherName.toLowerCase().replaceAll(' ', '');
  }
}