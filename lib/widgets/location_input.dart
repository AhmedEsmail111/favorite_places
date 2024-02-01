import 'dart:convert';

import 'package:favorite_places/models/consts.dart';
import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.setLocation});

  final void Function(PlaceLocation location) setLocation;

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  // the current location of the user
  PlaceLocation? _pickedLocation;
  // a bool to indicate whether we are loading a location or not
  var _isGettingLocation = false;
  // a getter to get  a location image based on the lat and lng using google maps static api
  String get locationImage {
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%$lat,$lng&key=$kAppkey';
  }

  //  a method which will use a lat a long and will return a get the address of that
  // and will update the _pickedLocation Var
  void _saveLocation(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$kAppkey');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );

      _isGettingLocation = false;
    });
    widget.setLocation(_pickedLocation!);
  }

  // a method to get the current location of the user
  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });
    locationData = await location.getLocation();

    // extract the lat and lng of the location to use it in getting a human readable
    // address using google maps and http package
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    _saveLocation(lat, lng);
  }

  //  a method to get the location of the user by selecting it on a map
  _selectOnMap() async {
    final location = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (ctx) => const MapScreen()),
    );
    if (location == null) {
      return;
    }
    _saveLocation(location.latitude, location.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location chosen yet!',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (_isGettingLocation) {
      previewContent = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pickedLocation != null && locationImage != '') {
      previewContent = FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: NetworkImage(
          locationImage,
        ),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: previewContent,
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: Text(
                'Get Current Location',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: Text(
                'Search on Map',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
