import 'package:favorite_places/screens/new_place_screen.dart';
import 'package:favorite_places/widgets/places_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  void _addNewPlace(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const NewPlaceScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
              onPressed: () {
                _addNewPlace(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: const PlacesTiles(),
    );
  }
}
