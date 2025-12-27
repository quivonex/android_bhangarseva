// screens/order_confirmation_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Image compression
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

// UPDATED COLOR THEME
const PRIMARY = Color(0xFF6FAE3E);       // Primary Green (Recycle / Nature)
const PRIMARY_LIGHT = Color(0xFFF4F7F3); // Light Background
const PRIMARY_DARK = Color(0xFF3E6B2C);  // Dark Green (Headers, buttons)
const ACCENT = Color(0xFFC48A3A);        // Accent Gold/Brown (Highlights, prices)
const ERROR = Color(0xFFB93D3D);         // Error remains same
const NAV_BAR_BLUE = Color(0xFF1F4E79);  // Primary Blue (AppBar / BottomNav)
const TEXT_DARK = Color(0xFF1E1E1E);     // Text Dark

class OrderConfirmationScreen extends StatefulWidget {
  final OrderData orderData;

  const OrderConfirmationScreen({
    super.key,
    required this.orderData,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isSubmitting = false;
  List<File> _selectedImages = [];
  List<Map<String, dynamic>> _timeSlots = [];
  String? _selectedTimeSlot;
  DateTime? _selectedDate = DateTime.now();
  bool _isLoadingTimeSlots = true;

  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _altPhone = TextEditingController();
  final _address = TextEditingController();
  final _landmark = TextEditingController();
  final _instructions = TextEditingController();
  final _upiId = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
    _address.text = widget.orderData.selectedLocation ?? "";
  }

  Future<void> _loadTimeSlots() async {
    setState(() => _isLoadingTimeSlots = true);
    try {
      final data = await ApiService.fetchTimeSlotsPost();
      if (data != null && data is List) {
        setState(() {
          _timeSlots = data.cast<Map<String, dynamic>>();
          if (_timeSlots.isNotEmpty) {
            _selectedTimeSlot = _timeSlots[0]['time_range'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to load time slots: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoadingTimeSlots = false);
    }
  }

  // PICK IMAGE + COMPRESS + CONVERT TO WEBP
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? picked = await _picker.pickImage(
          source: source,
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 85,
        );

        if (picked != null) {
          await _compressAndAdd(File(picked.path));
        }
      } else {
        final List<XFile>? pickedFiles = await _picker.pickMultiImage(
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 85,
        );

        if (pickedFiles != null) {
          for (var file in pickedFiles) {
            await _compressAndAdd(File(file.path));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image pick failed: $e")),
        );
      }
    }
  }

  // 🔥 COMPRESS IMAGE + CONVERT TO WEBP
  Future<void> _compressAndAdd(File originalFile) async {
    try {
      final dir = originalFile.parent.path;
      final name = originalFile.path.split('/').last;

      final compressedJpgPath = '$dir/compressed_$name';
      final webpPath = '$dir/${name.split('.').first}.webp';

      // Step 1 → JPEG compression
      final compressedResult = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        compressedJpgPath,
        quality: 80,
        minWidth: 1000,
        minHeight: 1000,
      );

      final File jpgFile =
      compressedResult != null ? File(compressedResult.path) : originalFile;

      // Step 2 → Convert JPEG → WEBP
      final webpResult = await FlutterImageCompress.compressAndGetFile(
        jpgFile.path,
        webpPath,
        quality: 80,
        format: CompressFormat.webp,
      );

      final File finalFile =
      webpResult != null ? File(webpResult.path) : jpgFile;

      if (mounted) {
        setState(() {
          _selectedImages.add(finalFile);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image compression failed: $e")),
        );
      }
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      _showSnack("Please upload at least 1 photo");
      return;
    }

    if (_selectedTimeSlot == null) {
      _showSnack("Please select a time slot");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.createSellingDetail(
        userId: await ApiService.getUserID(),
        date: _formatSelectedDate(),
        timeSlotId: _selectedTimeSlot!,
        latitude: widget.orderData.latitude ?? 17.0,
        longitude: widget.orderData.longitude ?? 74.0,
        address: _address.text,
        contact: _phone.text,
        altContact: _altPhone.text.isEmpty ? _phone.text : _altPhone.text,
        personName: _name.text,
        subProducts:
        widget.orderData.calculationRequests.map((e) => e.subProductId).toList(),
        productDetails: widget.orderData.calculationRequests.map((req) {
          return {
            "sub_product_id": req.subProductId,
            "sub_product_name": req.subProductName,
            "weight": req.estimatedWeight,
          };
        }).toList(),
        photos: _selectedImages,
        instructions: _instructions.text,
        landmark: _landmark.text,
        userUpiId: _upiId.text,
      );

      if (response != null && response['status'] == 'success') {
        _showSuccess(response);
      } else {
        _showSnack(response?['message'] ?? "Submission failed");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatSelectedDate() {
    final d = _selectedDate ?? DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  void _showSuccess(Map<String, dynamic> resp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: PRIMARY),
            const SizedBox(width: 10),
            const Text("Order Placed!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recycling, size: 50, color: PRIMARY),
            const SizedBox(height: 10),
            Text("Order ID: ${resp['order_id']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(resp['message'] ?? "Your order has been placed successfully"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("Go Home", style: TextStyle(color: PRIMARY)),
          )
        ],
      ),
    );
  }

  // ---------------- UI BUILDING ----------------

  @override
  Widget build(BuildContext context) {
    final items = widget.orderData.calculationResponse.items;
    final grand = widget.orderData.calculationResponse.grandTotals;

    return Scaffold(
      backgroundColor: PRIMARY_LIGHT,
      appBar: AppBar(
        backgroundColor: NAV_BAR_BLUE,
        title: const Text("Confirm Order", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: PRIMARY))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _orderSummaryCard(items, grand),
                    const SizedBox(height: 20),
                    _buildText(_name, "Your Name",
                        validator: (v) => v!.isEmpty ? "Enter name" : null),
                    const SizedBox(height: 12),
                    _buildText(_phone, "Contact Number",
                        type: TextInputType.phone,
                        validator: (v) => v!.length != 10
                            ? "Enter valid 10-digit number"
                            : null),
                    const SizedBox(height: 12),
                    _buildText(_altPhone, "Alternate Contact",
                        type: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildText(_address, "Address", maxLines: 2),
                    const SizedBox(height: 12),
                    _buildText(_landmark, "Landmark"),
                    const SizedBox(height: 12),
                    _buildText(_upiId, "UPI ID"),
                    const SizedBox(height: 12),

                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                          DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PRIMARY_LIGHT.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ACCENT),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatSelectedDate(), style: const TextStyle(color: TEXT_DARK)),
                            const Icon(Icons.calendar_month, color: PRIMARY),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildText(_instructions, "Special Instructions",
                        maxLines: 2),
                    const SizedBox(height: 16),

                    _isLoadingTimeSlots
                        ? const Center(
                        child: CircularProgressIndicator(
                            color: PRIMARY))
                        : _timeSlots.isEmpty
                        ? const Text("No time slots available",
                        style: TextStyle(color: ERROR))
                        : DropdownButtonFormField<String>(
                      value: _selectedTimeSlot,
                      decoration: _decor("Select Time Slot"),
                      items: _timeSlots
                          .map<DropdownMenuItem<String>>((slot) {
                        return DropdownMenuItem<String>(
                          value: slot['time_range'],
                          child: Text(slot['time_range']),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedTimeSlot = val),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text("Take Photo"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NAV_BAR_BLUE,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            label: const Text("Gallery"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NAV_BAR_BLUE,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _photoGrid(),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NAV_BAR_BLUE,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Confirm & Submit",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: PRIMARY_LIGHT.withOpacity(0.15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ACCENT)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PRIMARY)),
    );
  }

  Widget _buildText(TextEditingController c, String label,
      {TextInputType type = TextInputType.text,
        int maxLines = 1,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: type,
      validator: validator,
      style: const TextStyle(color: TEXT_DARK),
      decoration: _decor(label),
    );
  }

  Widget _orderSummaryCard(List items, dynamic grand) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [PRIMARY_LIGHT, Colors.white]),
        boxShadow: [
          BoxShadow(
            color: PRIMARY.withOpacity(0.15),
            blurRadius: 10,
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.shopping_bag, color: PRIMARY),
              SizedBox(width: 10),
              Text("Order Summary",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.circle,
                      size: 8, color: PRIMARY.withOpacity(0.7)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.subProductName, style: const TextStyle(color: TEXT_DARK))),
                  Text("${item.estimatedWeight} ${item.unit}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: PRIMARY)),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Earnings:",
                  style: TextStyle(fontWeight: FontWeight.bold, color: TEXT_DARK)),
              Text("₹${grand.totalExtraMoney.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 20,
                      color: ACCENT,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photoGrid() {
    if (_selectedImages.isEmpty) {
      return const Text("No photos added",
          style: TextStyle(color: Colors.black));
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _selectedImages.asMap().entries.map((entry) {
        int idx = entry.key;
        File img = entry.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(img, width: 90, height: 90, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.cancel, color: ERROR),
                  onPressed: () {
                    setState(() => _selectedImages.removeAt(idx));
                  },
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _altPhone.dispose();
    _address.dispose();
    _landmark.dispose();
    _instructions.dispose();
    _upiId.dispose();
    super.dispose();
  }
}
