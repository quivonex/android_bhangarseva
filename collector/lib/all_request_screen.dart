// screens/all_requests_screen.dart
import 'package:collector/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const primaryGold = Color(0xFFb59d31);
const darkBrown = Color(0xFF4a3b1a);

class AllRequestsScreen extends StatefulWidget {

  const AllRequestsScreen({
    super.key,
  });

  @override
  State<AllRequestsScreen> createState() => _AllRequestsScreenState();
}

class _AllRequestsScreenState extends State<AllRequestsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allRequests = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Date filter variables
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default dates (last 30 days)
    _toDate = DateTime.now();
    _fromDate = _toDate!.subtract(const Duration(days: 30));
    _updateDateControllers();
    _loadAllRequests();
  }

  void _updateDateControllers() {
    _fromDateController.text = _formatDateForDisplay(_fromDate);
    _toDateController.text = _formatDateForDisplay(_toDate);
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDateForAPI(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        _updateDateControllers();
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
        _updateDateControllers();
      });
    }
  }

  Future<void> _loadAllRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiService.getPendingOrders(
        fromDate: _formatDateForAPI(_fromDate),
        toDate: _formatDateForAPI(_toDate),
      );

      if (response['status'] == 'success') {
        setState(() {
          _allRequests = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load requests';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _resetDateFilters() {
    setState(() {
      _toDate = DateTime.now();
      _fromDate = _toDate!.subtract(const Duration(days: 30));
      _updateDateControllers();
    });
    _loadAllRequests();
  }

  List get _pendingRequests {
    return _allRequests.where((request) {
      final sellingDetail = request['selling_detail'];
      return sellingDetail != null && sellingDetail['order_status'] == 'pending';
    }).toList();
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // From Date
            TextFormField(
              controller: _fromDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'From Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectFromDate(context),
                ),
              ),
              onTap: () => _selectFromDate(context),
            ),
            const SizedBox(height: 16),

            // To Date
            TextFormField(
              controller: _toDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'To Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectToDate(context),
                ),
              ),
              onTap: () => _selectToDate(context),
            ),

            const SizedBox(height: 8),
            Text(
              'Showing orders from ${_formatDateForDisplay(_fromDate)} to ${_formatDateForDisplay(_toDate)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _resetDateFilters();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadAllRequests();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply Filter'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    final sellingDetail = request['selling_detail'];
    final subProducts = sellingDetail['sub_product_details'] ?? [];
    final photos = sellingDetail['photos'] ?? [];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Order #${sellingDetail['order_id'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 16),

              _detailRow('Request ID', request['request_id']?.toString() ?? 'N/A'),
              _detailRow('Order ID', sellingDetail['order_id'] ?? 'N/A'),
              _detailRow('Customer Name', sellingDetail['available_person_name'] ?? 'N/A'),
              _detailRow('Contact', sellingDetail['contact'] ?? 'N/A'),
              _detailRow('Alt Contact', sellingDetail['alt_contact'] ?? 'N/A'),
              _detailRow('Address', ApiService.formatAddress(
                sellingDetail['address'] ?? '',
                (sellingDetail['latitude'] ?? 0).toDouble(),
                (sellingDetail['longitude'] ?? 0).toDouble(),
              )),
              _detailRow('Items', ApiService.formatSubProducts(subProducts)),
              _detailRow('Total Weight', '${ApiService.calculateTotalWeight(subProducts).toStringAsFixed(1)} kg'),
              _detailRow('Pickup Date', ApiService.formatDate(sellingDetail['date'] ?? '')),
              _detailRow('Time Slot', sellingDetail['time_slot'] ?? 'N/A'),
              _detailRow('Requested At', ApiService.formatDateTime(request['requested_at'] ?? '')),
              _detailRow('UPI ID', sellingDetail['user_upi_id'] ?? 'N/A'),

              // Photos Section
              if (photos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Photos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photo['photo'] ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              const Text(
                'Pickup Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Please contact customer before visiting\n'
                    '• Collect items from the given address\n'
                    '• Verify items and weight before accepting\n'
                    '• Confirm pickup date and time slot\n'
                    '• Process payment upon collection',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAcceptRequest(Map<String, dynamic> request) {
    final sellingDetail = request['selling_detail'];
    final requestId = request['request_id'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Text(
          'Are you sure you want to accept order #${sellingDetail['order_id'] ?? 'N/A'} '
              'from ${sellingDetail['available_person_name'] ?? 'Customer'}?\n\n'
              'Items: ${ApiService.formatSubProducts(sellingDetail['sub_product_details'] ?? [])}\n'
              'Weight: ${ApiService.calculateTotalWeight(sellingDetail['sub_product_details'] ?? []).toStringAsFixed(1)} kg\n'
              'Date: ${ApiService.formatDate(sellingDetail['date'] ?? '')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.acceptOrder(
                  requestId: requestId,
                  notes: 'Order accepted',
                );

                // Remove from local list
                setState(() {
                  _allRequests.removeWhere((req) => req['request_id'] == requestId);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order #${sellingDetail['order_id']} accepted successfully'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to accept order: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _handleRejectRequest(Map<String, dynamic> request) {
    final sellingDetail = request['selling_detail'];
    final requestId = request['request_id'];
    String rejectionReason = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reject Order'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please select reason for rejection:'),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    rejectionReason = value;
                  },
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter reason for rejection...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: rejectionReason.isEmpty
                    ? null
                    : () async {
                  Navigator.pop(context);
                  try {
                    await _apiService.rejectOrder(
                      requestId: requestId,
                      reason: rejectionReason,
                    );

                    // Remove from local list
                    setState(() {
                      _allRequests.removeWhere((req) => req['request_id'] == requestId);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order #${sellingDetail['order_id']} rejected'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to reject order: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
        actions: [
          // Date Filter Button
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showDateFilterDialog,
            tooltip: 'Filter by date',
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAllRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Filter Info Card
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing orders from ${_formatDateForDisplay(_fromDate)} to ${_formatDateForDisplay(_toDate)}',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showDateFilterDialog,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      color: primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange[50],
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.orange[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage.isNotEmpty
                        ? _errorMessage
                        : '${_pendingRequests.length} pending orders from selected date range',
                    style: TextStyle(
                      color: _errorMessage.isNotEmpty ? Colors.red : Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
              ),
            )
                : _pendingRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Pending Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No orders found from ${_formatDateForDisplay(_fromDate)} to ${_formatDateForDisplay(_toDate)}',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingRequests.length,
              itemBuilder: (context, index) {
                final request = _pendingRequests[index];
                final sellingDetail = request['selling_detail'];
                final subProducts = sellingDetail['sub_product_details'] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${sellingDetail['order_id'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: darkBrown,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.pending,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'PENDING',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Customer Info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryGold.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                color: primaryGold,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sellingDetail['available_person_name'] ?? 'Customer',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  sellingDetail['contact'] ?? 'No contact',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Details Grid
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _detailItem(
                                      icon: Icons.location_on,
                                      title: 'Address',
                                      value: ApiService.formatAddress(
                                        sellingDetail['address'] ?? '',
                                        (sellingDetail['latitude'] ?? 0).toDouble(),
                                        (sellingDetail['longitude'] ?? 0).toDouble(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _detailItem(
                                      icon: Icons.shopping_bag,
                                      title: 'Items',
                                      value: ApiService.formatSubProducts(subProducts),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _detailItem(
                                      icon: Icons.calendar_today,
                                      title: 'Date',
                                      value: ApiService.formatDate(sellingDetail['date'] ?? ''),
                                    ),
                                  ),
                                  Expanded(
                                    child: _detailItem(
                                      icon: Icons.scale,
                                      title: 'Weight',
                                      value: '${ApiService.calculateTotalWeight(subProducts).toStringAsFixed(1)} kg',
                                      valueColor: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showRequestDetails(request),
                                icon: const Icon(Icons.visibility),
                                label: const Text('View Details'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryGold,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: primaryGold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleRejectRequest(request),
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleAcceptRequest(request),
                                icon: const Icon(Icons.check),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAllRequests,
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }
}