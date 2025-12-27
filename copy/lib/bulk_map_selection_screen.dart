import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/product_model.dart';
import 'bulk_order_confirmation_screen.dart';


const PRIMARY_BLUE = Color(0xFF1F4E79);

class BulkMapSelectionScreen extends StatefulWidget {
  final CalculationResponse calculationResponse;
  final String productName;
  final List<CalculationRequest> calculationRequests;

  const BulkMapSelectionScreen ({
    Key? key,
    required this.calculationResponse,
    required this.productName,
    required this.calculationRequests,
  }) : super(key: key);

  @override
  State<BulkMapSelectionScreen > createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<BulkMapSelectionScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;
  String _selectedAddress = "Tap on map to select location";
  bool _locationSelected = false;

  BitmapDescriptor? _customMarker;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadSmallMarker();
  }

  Future<void> _loadSmallMarker() async {
    final ByteData data =
    await rootBundle.load('assets/icons/img.png');

    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 60,
      targetHeight: 60,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? bytes =
    await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    _customMarker =
        BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());

    setState(() {});
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        setState(() {
          _selectedAddress =
          "${p.name}, ${p.street}, ${p.subLocality}, "
              "${p.locality}, ${p.administrativeArea}, "
              "${p.postalCode}, ${p.country}";
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = "Unable to fetch address";
      });
    }
  }

  Future<void> _goToMyLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final LatLng loc =
    LatLng(position.latitude, position.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: loc, zoom: 15),
      ),
    );

    setState(() {
      _selectedLatLng = loc;
      _locationSelected = true;
    });

    await _getAddressFromLatLng(loc);
  }

  void _proceedNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BulkOrderConfirmationScreen(
          orderData: OrderData(
            calculationResponse: widget.calculationResponse,
            productName: widget.productName,
            calculationRequests: widget.calculationRequests,
            selectedLocation: _selectedAddress,
            latitude: _selectedLatLng!.latitude,
            longitude: _selectedLatLng!.longitude,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PRIMARY_BLUE.withOpacity(0.05),
      appBar: AppBar(
        title: const Text("Pickup Location"),
        centerTitle: true,
        backgroundColor: PRIMARY_BLUE,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              myLocationEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (LatLng latLng) async {
                setState(() {
                  _selectedLatLng = latLng;
                  _locationSelected = true;
                });
                await _getAddressFromLatLng(latLng);
              },
              markers: _selectedLatLng == null
                  ? {}
                  : {
                Marker(
                  markerId:
                  const MarkerId("selectedLocation"),
                  position: _selectedLatLng!,
                  icon: _customMarker ??
                      BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(
                    title: "Pickup Location",
                    snippet: _selectedAddress,
                  ),
                ),
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: [
                BoxShadow(
                  color: PRIMARY_BLUE.withOpacity(0.25),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedAddress,
                  style: TextStyle(
                    fontSize: 15,
                    color: PRIMARY_BLUE,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                    _locationSelected ? _proceedNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_BLUE,
                      disabledBackgroundColor:
                      PRIMARY_BLUE.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_BLUE,
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
