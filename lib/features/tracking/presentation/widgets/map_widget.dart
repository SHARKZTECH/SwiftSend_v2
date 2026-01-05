import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DeliveryMapWidget extends StatefulWidget {
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;
  final LatLng? riderLocation;
  final bool showRoute;
  final bool interactive;
  final double height;

  const DeliveryMapWidget({
    super.key,
    this.pickupLocation,
    this.dropoffLocation,
    this.riderLocation,
    this.showRoute = true,
    this.interactive = true,
    this.height = 300,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  late MapController _mapController;

  // Default to Nairobi, Kenya
  static const LatLng _defaultCenter = LatLng(-1.2921, 36.8219);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  LatLng get _mapCenter {
    if (widget.riderLocation != null) {
      return widget.riderLocation!;
    }
    if (widget.pickupLocation != null) {
      return widget.pickupLocation!;
    }
    return _defaultCenter;
  }

  List<Marker> get _markers {
    final markers = <Marker>[];

    // Pickup marker
    if (widget.pickupLocation != null) {
      markers.add(
        Marker(
          point: widget.pickupLocation!,
          width: 40,
          height: 40,
          child: const _MapMarker(
            icon: Icons.location_on,
            color: Colors.green,
            label: 'P',
          ),
        ),
      );
    }

    // Dropoff marker
    if (widget.dropoffLocation != null) {
      markers.add(
        Marker(
          point: widget.dropoffLocation!,
          width: 40,
          height: 40,
          child: const _MapMarker(
            icon: Icons.flag,
            color: Colors.red,
            label: 'D',
          ),
        ),
      );
    }

    // Rider marker
    if (widget.riderLocation != null) {
      markers.add(
        Marker(
          point: widget.riderLocation!,
          width: 50,
          height: 50,
          child: const _RiderMarker(),
        ),
      );
    }

    return markers;
  }

  List<Polyline> get _polylines {
    if (!widget.showRoute || 
        widget.pickupLocation == null || 
        widget.dropoffLocation == null) {
      return [];
    }

    final points = <LatLng>[widget.pickupLocation!];
    
    // Add rider location if available (shows progress)
    if (widget.riderLocation != null) {
      points.add(widget.riderLocation!);
    }
    
    points.add(widget.dropoffLocation!);

    return [
      Polyline(
        points: points,
        strokeWidth: 4,
        color: Colors.blue.withValues(alpha: 0.7),
        isDotted: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 13,
              interactionOptions: InteractionOptions(
                flags: widget.interactive
                    ? InteractiveFlag.all
                    : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.swiftsend.app',
              ),
              if (_polylines.isNotEmpty)
                PolylineLayer(polylines: _polylines),
              if (_markers.isNotEmpty)
                MarkerLayer(markers: _markers),
            ],
          ),
          
          // Map controls
          if (widget.interactive)
            Positioned(
              right: 8,
              bottom: 8,
              child: Column(
                children: [
                  _MapControlButton(
                    icon: Icons.add,
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom + 1,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _MapControlButton(
                    icon: Icons.remove,
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom - 1,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _MapControlButton(
                    icon: Icons.my_location,
                    onPressed: () {
                      _mapController.move(_mapCenter, 15);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MapMarker({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _RiderMarker extends StatelessWidget {
  const _RiderMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.motorcycle,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
