import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget{

  final double latitude;
  final double longitude;

  MapsPage({Key? key, required this.latitude, required this.longitude}) : super(key:key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage>{

  final _controller = Completer<GoogleMapController>();
  StreamSubscription<Position>? _subscription;

  @override
  void initState() {
    super.initState();
    _monitorarLocalizacao();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Usando Mapa interno'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: (LatLng(widget.latitude,widget.longitude)),
            infoWindow: InfoWindow(title: 'Ponto 1')
          )
        },
        initialCameraPosition: CameraPosition(
          target:LatLng(widget.latitude, widget.longitude),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller){
          _controller.complete(controller);
        },
        myLocationEnabled: true,
      ),
    );
  }

  void _monitorarLocalizacao() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    _subscription = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position posicao) async {
          final controller = await _controller.future;
          final zoom = await controller.getZoomLevel();
          controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(posicao.latitude,posicao.longitude),
              zoom: zoom
              )
            )
          );
        }
    );
  }

}