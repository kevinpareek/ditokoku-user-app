import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

import 'PaymentDetailPage.dart';

class PascabayarTopUpPage extends StatefulWidget {
  final String serviceName;
  final String serviceDescription;
  final String logoPath;
  final String buyerSkuCode;
  final Color? serviceColor;
  final String serviceType; // 'pln', 'internet', 'pdam', 'bpjs'
final bool isNetworkIcon;


  const PascabayarTopUpPage({
    super.key,
    required this.serviceName,
    required this.serviceDescription,
    required this.logoPath,
    required this.buyerSkuCode,
    this.serviceColor,
    required this.serviceType,
    this.isNetworkIcon = false,
  });

  @override
  State<PascabayarTopUpPage> createState() => _PascabayarTopUpPageState();
}

class _PascabayarTopUpPageState extends State<PascabayarTopUpPage> {
  final TextEditingController _customerNoController = TextEditingController();
  bool isCheckingBill = false;
  Map<String, dynamic>? billInfo;
  String? errorMessage;
  
  bool isAgen = false;
  bool isLoadingAgen = true;
  
  Map<String, dynamic>? productData; // ✅ Untuk menyimpan data product dari API

  @override
  void initState() {
    super.initState();
    _checkAgenStatus();
    _fetchProductData(); // ✅ Fetch product data saat init
  }

  @override
  void dispose() {
    _customerNoController.dispose();
    super.dispose();
  }

  Future<void> _checkAgenStatus() async {
    if (!AuthHelper.isLoggedIn()) {
      setState(() {
        isLoadingAgen = false;
        isAgen = false;
      });
      return;
    }

    try {
      setState(() {
        isLoadingAgen = true;
      });

      final profileController = Get.find<ProfileController>();
      
      if (profileController.userInfoModel == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (profileController.userInfoModel == null) {
          setState(() {
            isLoadingAgen = false;
          });
          return;
        }
      }

      final userId = profileController.userInfoModel!.id;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.token) ?? '';
      
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/users/agen/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            isAgen = true;
            isLoadingAgen = false;
          });
        } else {
          setState(() {
            isAgen = false;
            isLoadingAgen = false;
          });
        }
      } else {
        setState(() {
          isAgen = false;
          isLoadingAgen = false;
        });
      }
    } catch (e) {
      print('Error checking agen status: $e');
      setState(() {
        isAgen = false;
        isLoadingAgen = false;
      });
    }
  }

  // ✅ Fetch product data dari API products berdasarkan buyer_sku_code
  Future<void> _fetchProductData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> allProducts = json.decode(response.body);
        
        print('🔍 Looking for buyer_sku_code: ${widget.buyerSkuCode}');
        
        // Cari product yang buyer_sku_code nya cocok
        final product = allProducts.firstWhere(
          (p) => p['buyer_sku_code'] == widget.buyerSkuCode,
          orElse: () => null,
        );
        
        if (product != null) {
          print('✅ Product found: ${product['product_name']}');
          print('   price: ${product['price']}');
          print('   priceTierTwo: ${product['priceTierTwo']}');
          
          setState(() {
            productData = product;
          });
        } else {
          print('❌ Product not found for buyer_sku_code: ${widget.buyerSkuCode}');
        }
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  Color get serviceColor {
    return widget.serviceColor ?? _getDefaultColor();
  }

  Color _getDefaultColor() {
    switch (widget.serviceType) {
      case 'pln':
        return Colors.blue[700]!;
      case 'internet':
        return Colors.red[700]!;
      case 'pdam':
        return Colors.blue[600]!;
      case 'bpjs':
        return Colors.green[700]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData get serviceIcon {
    switch (widget.serviceType) {
      case 'pln':
        return Icons.flash_on;
      case 'internet':
        return Icons.wifi;
      case 'pdam':
        return Icons.water_drop;
      case 'bpjs':
        return Icons.local_hospital;
      default:
        return Icons.receipt_long;
    }
  }

  String get inputHint {
    switch (widget.serviceType) {
      case 'pln':
        return 'Masukan ID Pelanggan PLN';
      case 'internet':
        return 'Masukan Nomor Pelanggan';
      case 'pdam':
        return 'Masukan Nomor Pelanggan PDAM';
      case 'bpjs':
        return 'Masukan Nomor BPJS';
      default:
        return 'Masukan Nomor Pelanggan';
    }
  }

  String get inputLabel {
    switch (widget.serviceType) {
      case 'pln':
        return 'ID Pelanggan';
      case 'internet':
      case 'pdam':
        return 'Nomor Pelanggan';
      case 'bpjs':
        return 'Nomor BPJS';
      default:
        return 'Nomor Pelanggan';
    }
  }

  Future<void> _checkBill() async {
    // ✅ Validasi: Cek apakah product data sudah ada
    if (productData == null) {
      setState(() {
        errorMessage = 'Produk tidak tersedia. Silakan coba lagi nanti.';
      });
      return;
    }
    
    if (_customerNoController.text.isEmpty) {
      setState(() {
        errorMessage = 'Masukkan ${inputLabel.toLowerCase()} terlebih dahulu';
      });
      return;
    }

    setState(() {
      isCheckingBill = true;
      billInfo = null;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/inquiry-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_no': _customerNoController.text,
          'buyer_sku_code': widget.buyerSkuCode,
          'testing': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          setState(() {
            billInfo = data['digiflazz_response']['data'];
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Gagal mengambil data tagihan';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Gagal terhubung ke server. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error checking bill: $e');
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isCheckingBill = false;
      });
    }
  }

  String _formatPrice(dynamic price) {
    double priceDouble = 0;
    if (price is String) {
      priceDouble = double.tryParse(price) ?? 0;
    } else if (price is int) {
      priceDouble = price.toDouble();
    } else if (price is double) {
      priceDouble = price;
    }
    
    return 'Rp${priceDouble.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}';
  }

  // Helper function untuk mendapatkan harga selling price yang benar
  String _getSellingPrice() {
    if (billInfo == null) return '0';
    
    // Selalu ambil selling_price dari inquiry response (ini total tagihan dari provider)
    return billInfo!['selling_price']?.toString() ?? '0';
  }
  
  // ✅ Helper function untuk mendapatkan biaya admin dari product data
  String _getAdminPrice() {
    if (productData == null) {
      print('⚠️ productData is null, returning 0');
      return '0';
    }
    
    print('📊 isAgen: $isAgen');
    print('   productData price: ${productData!['price']}');
    print('   productData priceTierTwo: ${productData!['priceTierTwo']}');
    
    // Jika agen, ambil dari 'price' di product
    if (isAgen) {
      return productData!['price']?.toString() ?? '0';
    }
    
    // Jika bukan agen, ambil dari 'priceTierTwo' di product
    return productData!['priceTierTwo']?.toString() ?? productData!['price']?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/image/goback.png',
                  width: 31,
                  height: 31,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Text(
              widget.serviceName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with logo and input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Service logo
                  Container(
                    width: 120,
                    height: 120,
                    child: Center(
                      child: Image.asset(
                        widget.logoPath,
                        width: 101,
                        height: 101,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 101,
                            height: 101,
                            decoration: BoxDecoration(
                              color: serviceColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              serviceIcon,
                              size: 60,
                              color: serviceColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Input section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Masukan ${inputLabel}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      // Customer number input
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x662F318B),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Text input
                              Expanded(
                                child: TextFormField(
                                  controller: _customerNoController,
                                  keyboardType: widget.serviceType == 'bpjs' 
                                    ? TextInputType.text
                                    : TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: inputHint,
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFBAB0B0),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Service logo on the right side of input
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Image.asset(
                                  widget.logoPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: serviceColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        serviceIcon,
                                        size: 16,
                                        color: serviceColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Check button
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: (isCheckingBill || productData == null) ? null : _checkBill, // ✅ Disable jika product belum ada
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x662F318B),
                              width: 1.5,
                            ),
                            color: productData == null ? Colors.grey[300] : null, // ✅ Visual indicator disabled
                          ),
                          child: Center(
                            child: isCheckingBill
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(serviceColor),
                                  ),
                                )
                              : Image.asset(
                                  'assets/image/search.png',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                  color: productData == null ? Colors.grey : null, // ✅ Grayscale jika disabled
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.search,
                                      color: productData == null ? Colors.grey : serviceColor,
                                      size: 24,
                                    );
                                  },
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Error message
            if (errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Bill info display
            if (billInfo != null) ...[
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Tagihan ${_getServiceTypeTitle()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Customer info
                    _buildInfoRow('Nama Pelanggan', billInfo!['customer_name'] ?? '-'),
                    _buildInfoRow(inputLabel, billInfo!['customer_no'] ?? '-'),
                    
                    // Service specific info
                    ..._buildServiceSpecificInfo(),
                    
                    // Detail tagihan per periode
                    if (billInfo!['desc'] != null && 
                        billInfo!['desc']['detail'] != null && 
                        (billInfo!['desc']['detail'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Detail Tagihan:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      ...((billInfo!['desc']['detail'] as List).map((detail) =>
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Periode', detail['periode'] ?? '-'),
                              _buildInfoRow('Nilai Tagihan', _formatPrice(detail['nilai_tagihan'])),
                              _buildInfoRow('Biaya Admin', _formatPrice(_getAdminPrice())), // ✅ Ambil dari product data
                              if (detail['denda'] != null && detail['denda'] != '0')
                                _buildInfoRow('Denda', _formatPrice(detail['denda'])),
                              if (detail['materai'] != null && detail['materai'] != '0')
                                _buildInfoRow('Materai', _formatPrice(detail['materai'])),
                            ],
                          ),
                        ),
                      )),
                    ],
                    
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Tagihan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _formatPrice(_getSellingPrice()), // ✅ Sudah benar menggunakan helper function
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: serviceColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Pay button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Create product object for PaymentDetailPage dengan harga yang benar berdasarkan status agen
                          final productForPayment = {
                            'product_name': '${widget.serviceName} - ${billInfo!['customer_name']}',
                            'price': _getSellingPrice(), // ✅ Menggunakan helper function untuk selling price (price untuk agen, priceTierTwo untuk non-agen)
                            'admin': _getAdminPrice(), // ✅ Menggunakan helper function untuk admin price (admin untuk agen, admin_tier_two untuk non-agen)
                            'buyer_sku_code': billInfo!['buyer_sku_code'],
                            'ref_id': billInfo!['ref_id'],
                          };
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentDetailPage(
                                product: productForPayment,
                                phoneNumber: _customerNoController.text,
                                provider: widget.serviceName,
                                providerLogo: widget.logoPath,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: serviceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.serviceType == 'bpjs' ? 'BAYAR BPJS' : 'BAYAR TAGIHAN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getServiceTypeTitle() {
    switch (widget.serviceType) {
      case 'pln':
        return 'PLN';
      case 'internet':
        return 'Internet & TV';
      case 'pdam':
        return 'PDAM';
      case 'bpjs':
        return 'BPJS';
      default:
        return '';
    }
  }

  List<Widget> _buildServiceSpecificInfo() {
    List<Widget> widgets = [];
    
    if (billInfo!['desc'] != null) {
      final desc = billInfo!['desc'];
      
      widgets.add(const SizedBox(height: 12));
      widgets.add(const Divider());
      widgets.add(const SizedBox(height: 12));
      
      switch (widget.serviceType) {
        case 'pln':
          if (desc['tarif'] != null) {
            widgets.add(_buildInfoRow('Tarif', desc['tarif']));
          }
          if (desc['daya'] != null) {
            widgets.add(_buildInfoRow('Daya', '${desc['daya']} VA'));
          }
          break;
          
        case 'pdam':
          if (desc['golongan'] != null) {
            widgets.add(_buildInfoRow('Golongan', desc['golongan']));
          }
          if (desc['meter_awal'] != null && desc['meter_akhir'] != null) {
            final pemakaian = (int.tryParse(desc['meter_akhir'].toString()) ?? 0) - 
                             (int.tryParse(desc['meter_awal'].toString()) ?? 0);
            widgets.add(_buildInfoRow('Pemakaian', '${desc['meter_akhir']} - ${desc['meter_awal']} = $pemakaian m³'));
          }
          break;
          
        case 'bpjs':
          if (desc['kelas'] != null) {
            widgets.add(_buildInfoRow('Kelas', desc['kelas']));
          }
          if (desc['faskes'] != null) {
            widgets.add(_buildInfoRow('Faskes', desc['faskes']));
          }
          break;
          
        case 'internet':
          // Add specific info for internet if needed
          break;
      }
      
      if (desc['lembar_tagihan'] != null) {
        widgets.add(_buildInfoRow('Lembar Tagihan', '${desc['lembar_tagihan']}'));
      }
    }
    
    return widgets;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}