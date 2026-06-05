import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart'; // [TAMBAHAN] untuk video player
import 'dart:ui';

class SenderPage extends StatefulWidget {
  final String sessionKey;
  // [MODIFIKASI] Menambahkan userRole untuk validasi Add Global Sender
  // Default 'member' agar tidak error jika dari halaman sebelumnya belum mengirim argumen ini
  final String userRole; 

  const SenderPage({
    super.key, 
    required this.sessionKey,
    this.userRole = 'member', // Ganti nilainya saat memanggil SenderPage() dari route Anda
  });

  @override
  State<SenderPage> createState() => _SenderPageState();
}

class _SenderPageState extends State<SenderPage> with TickerProviderStateMixin {
  // Constants
  static const String baseUrl = "http://marxxxnotdev.danzxncloud.biz.id:11662";
  
  // [MODIFIKASI WARNA: TEMA GLOWING GREY]
  static const Color primaryColor = Color(0xFFE0E0E0); // Abu-abu menyala (Silver)
  static const Color accentColor = Color(0xFFFFFFFF); // Putih untuk highlight
  static const Color secondaryColor = Color(0xFF050505); // Hitam pekat untuk kontras

  // State variables
  Map<String, dynamic> connections = {"private": [], "global": []};
  bool isLoading = false;
  String _currentFilter = "all"; // Filter: "all", "private", "global"
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  // [TAMBAHAN] Controller untuk Video Background
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchSenders();
    _initVideoBackground(); // [TAMBAHAN] Memanggil fungsi inisialisasi video
  }

  // [TAMBAHAN] Fungsi untuk load video background
  Future<void> _initVideoBackground() async {
    try {
      _videoController = VideoPlayerController.asset('assets/videos/banner.mp4')
        ..initialize().then((_) {
          _videoController?.setLooping(true);
          _videoController?.setVolume(0.0);
          _videoController?.play();
          if (mounted) setState(() {});
        }).catchError((e) {
          debugPrint("Gagal memuat video background: $e");
        });
    } catch (e) {
       debugPrint("Exception saat memuat video: $e");
    }
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  Future<void> _fetchSenders() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService.getMySender(widget.sessionKey);

      if (res['valid'] == true) {
        print("RESPONSE FROM SERVER: ${res["connections"]}");

        setState(() {
          connections = res["connections"] ?? {"private": [], "global": []};
        });
      } else {
        _showErrorSnackBar(res['message'] ?? "Failed to fetch senders");
      }
    } catch (e) {
      debugPrint("Error fetching senders: $e");
      _showErrorSnackBar("Failed to fetch senders. Please try again.");
    }

    setState(() => isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade900.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.red.withOpacity(0.5)),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: primaryColor.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // =====================================================================
  // [MODIFIKASI] TAMPILAN DIALOG ADD SENDER SESUAI GAMBAR UI BARU
  // =====================================================================
  void _showAddSenderDialog() {
    final privateController = TextEditingController();
    final globalController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // Transparan karena cardnya punya warna
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // KARTU PRIVATE SENDER
              _buildSenderCard(
                title: "Add Private Sender",
                subtitle: "Sender ini hanya bisa digunakan oleh akun Anda sendiri.",
                icon: Icons.lock_person,
                themeColor: const Color(0xFF4285F4), // Warna Biru
                controller: privateController,
                isGlobal: false,
              ),
              const SizedBox(height: 24),
              
              // KARTU GLOBAL SENDER
              _buildSenderCard(
                title: "Add Global Sender",
                subtitle: "Sender publik yang bisa dipakai oleh semua member & owner.",
                icon: Icons.public,
                themeColor: const Color(0xFFE53935), // Warna Merah
                controller: globalController,
                isGlobal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget builder khusus untuk kartu add sender (Bisa digunakan untuk biru/merah)
  Widget _buildSenderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color themeColor,
    required TextEditingController controller,
    required bool isGlobal,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Background card gelap
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeColor, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron', // Mengikuti font awal
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: themeColor),
            decoration: InputDecoration(
              hintText: "Nomor WhatsApp",
              hintStyle: TextStyle(color: themeColor.withOpacity(0.7)),
              filled: true,
              fillColor: const Color(0xFF0A0A0A), // Background field hitam
              prefixIcon: Icon(Icons.phone, color: themeColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: themeColor),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => _handleRequestPairing(controller.text.trim(), isGlobal),
              child: const Text(
                "REQUEST PAIRING",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontFamily: 'Orbitron',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logika ketika tombol "REQUEST PAIRING" ditekan
  Future<void> _handleRequestPairing(String number, bool isGlobal) async {
    if (number.isEmpty) {
      _showErrorSnackBar("Nomor WhatsApp tidak boleh kosong");
      return;
    }

    // [MODIFIKASI] Validasi Role untuk Add Global Sender
    if (isGlobal) {
      final allowedRoles = ['founder', 'moderator', 'high admin', 'owner', 'reseller'];
      final userCurrentRole = widget.userRole.toLowerCase();
      
      if (!allowedRoles.contains(userCurrentRole)) {
        _showErrorSnackBar("Akses Ditolak! Hanya role khusus (Founder/Admin/Owner/dll) yang dapat menambah Global Sender.");
        return;
      }
    }

    Navigator.pop(context); // Tutup dialog setelah validasi awal sukses

    try {
      final res = await ApiService.getPairing(
        widget.sessionKey,
        number,
        isGlobal: isGlobal,
      );

      if (res['valid'] == true) {
        _showPairingCodeDialog(number, res['pairingCode']);
        _fetchSenders();
      } else {
        _showErrorSnackBar("Failed: ${res['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("Error adding sender: $e");
      _showErrorSnackBar("An error occurred. Please try again.");
    }
  }
  // =====================================================================

  void _showPairingCodeDialog(String number, String code) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phonelink_lock, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Pairing Code",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                      shadows: [Shadow(color: primaryColor, blurRadius: 5)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Number: $number",
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor.withOpacity(0.5)),
                              boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 10)],
                            ),
                            child: Text(
                              code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: accentColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                fontFamily: 'Orbitron',
                                shadows: [Shadow(color: accentColor, blurRadius: 10)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Enter this code in your WhatsApp app to complete pairing.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                        ),
                      ),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text("Copy Code"),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        _showSuccessSnackBar("Pairing code copied to clipboard!");
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                        shadowColor: primaryColor.withOpacity(0.5),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mengambil daftar sender berdasarkan filter yang dipilih
  List<dynamic> _getFilteredSenders() {
    switch (_currentFilter) {
      case "private":
        return connections["private"] ?? [];
      case "global":
        return connections["global"] ?? [];
      default:
      // "all" - gabungkan private dan global
        return [
          ...connections["private"] ?? [],
          ...connections["global"] ?? []
        ];
    }
  }

  // Menghitung total sender berdasarkan filter
  int _getSenderCount() {
    switch (_currentFilter) {
      case "private":
        return connections["private"]?.length ?? 0;
      case "global":
        return connections["global"]?.length ?? 0;
      default:
      // "all" - gabungkan private dan global
        return (connections["private"]?.length ?? 0) + (connections["global"]?.length ?? 0);
    }
  }

  int _getTotalSenderCount() {
    return (connections["private"]?.length ?? 0) + (connections["global"]?.length ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final totalSenders = _getTotalSenderCount();

    return Stack(
      children: [
        // --- Layer Video Background ---
        SizedBox.expand(
          child: _videoController != null && _videoController!.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              : Container(color: secondaryColor),
        ),

        // --- Layer Hitam Transparan Agar UI Terbaca ---
        Container(color: Colors.black.withOpacity(0.6)),

        // --- Layer Scaffold Konten Utama ---
        Scaffold(
          backgroundColor: Colors.transparent, 
          appBar: AppBar(
            backgroundColor: Colors.transparent, 
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              "My Senders (${_getSenderCount()})", 
              style: const TextStyle(
                color: primaryColor,
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: primaryColor, blurRadius: 2)],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: accentColor),
                  onPressed: _fetchSenders,
                ),
              ),
            ],
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabAnimation.value,
                child: FloatingActionButton(
                  backgroundColor: primaryColor,
                  elevation: 10,
                  onPressed: () {
                    _fabController.forward().then((_) {
                      _fabController.reverse();
                    });
                    _showAddSenderDialog();
                  },
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              );
            },
          ),
          body: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: accentColor,
            ),
          )
              : totalSenders == 0
              ? _buildEmptyState()
              : Column(
            children: [
              _buildFilterChips(),
              Expanded(child: _buildSenderList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip("All", "all"),
            const SizedBox(width: 8),
            _buildFilterChip("Private", "private"),
            const SizedBox(width: 8),
            _buildFilterChip("Global", "global"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _currentFilter == filter;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
      backgroundColor: Colors.white.withOpacity(0.05),
      selectedColor: primaryColor,
      checkmarkColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? primaryColor : Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 20)],
            ),
            child: const Icon(
              Icons.phone_disabled,
              color: Colors.white30,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No senders found",
            style: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add a sender to get started",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddSenderDialog,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text("Add Sender", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 5,
              shadowColor: primaryColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderList() {
    final filteredSenders = _getFilteredSenders();

    if (filteredSenders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.filter_list_off,
                color: primaryColor.withOpacity(0.5),
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                "No senders found in '${_currentFilter.toUpperCase()}' filter",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Try selecting a different filter or add a new sender.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSenders,
      color: accentColor,
      backgroundColor: secondaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSenders.length,
        itemBuilder: (context, index) {
          final sender = filteredSenders[index];
          final isGlobal = sender['owner'] == "global" || sender['role'] == "high owner";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isGlobal
                    ? accentColor.withOpacity(0.5)
                    : primaryColor.withOpacity(0.2),
              ),
              boxShadow: isGlobal ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ] : [],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isGlobal
                      ? accentColor.withOpacity(0.2)
                      : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.phone,
                  color: isGlobal ? accentColor : primaryColor,
                ),
              ),
              title: Text(
                sender['sessionName'] ?? 'Unknown',
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Type: ${sender['type'] ?? 'N/A'}",
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Owner: ${isGlobal ? 'Global (VIP)' : sender['owner'] ?? 'N/A'}",
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isGlobal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: const Text(
                        "VIP",
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Active",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _videoController?.dispose(); 
    super.dispose();
  }
}

// API Service
class ApiService {
  static const String _baseUrl = "http://marxxxnotdev.danzxncloud.biz.id:11662";

  static Future<Map<String, dynamic>> getMySender(String sessionKey) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/api/whatsapp/mySender?key=$sessionKey"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch senders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching senders: $e');
    }
  }

  static Future<Map<String, dynamic>> getPairing(String sessionKey, String number, {bool isGlobal = false}) async {
    try {
      final url = "$_baseUrl/api/whatsapp/getPairing?key=$sessionKey&number=$number${isGlobal ? "&isGlobal=true" : ""}";
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get pairing code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting pairing code: $e');
    }
  }
}