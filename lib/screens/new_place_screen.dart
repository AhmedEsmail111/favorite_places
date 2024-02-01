import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/providers/places_provider.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPlaceScreen extends ConsumerStatefulWidget {
  const NewPlaceScreen({super.key});
  @override
  ConsumerState<NewPlaceScreen> createState() {
    return _NewPlaceScreenState();
  }
}

class _NewPlaceScreenState extends ConsumerState<NewPlaceScreen> {
  // a var to control the selected image
  File? _selectedImage;
  // var for the location
  PlaceLocation? _userLocation;
  final _formKey = GlobalKey<FormState>();
  // vars to control the entered values
  var _enteredTitle = '';

  // a method to triger when submitting a place
  void _onSubmitPlace() {
    if (_formKey.currentState!.validate() &&
        _selectedImage != null &&
        _userLocation != null) {
      _formKey.currentState!.save();
      ref.read(favoritePlacesProvider.notifier).addPlace(
          title: _enteredTitle,
          image: _selectedImage!,
          location: _userLocation!);

      Navigator.of(context).pop();
    }
    if (_selectedImage == null || _userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please set all fields first.',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 3) {
                        return 'please enter a valid title.';
                      }
                      return null;
                    },
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text('title')),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.normal,
                        ),
                    onSaved: (value) {
                      _enteredTitle = value!;
                    },
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ImageInput(
              onPickImage: (image) {
                _selectedImage = image;
              },
            ),
            const SizedBox(
              height: 8,
            ),
            LocationInput(
              setLocation: (location) {
                _userLocation = location;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
                onPressed: _onSubmitPlace,
                icon: Icon(Icons.add,
                    color: Theme.of(context).colorScheme.onBackground),
                label: Text(
                  'Add Place',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                )),
          ],
        ),
      ),
    );
  }
}
