import 'package:favorite_places/providers/places_provider.dart';
import 'package:favorite_places/screens/place_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesTiles extends ConsumerStatefulWidget {
  const PlacesTiles({super.key});
  @override
  ConsumerState<PlacesTiles> createState() {
    return _PlacesTiles();
  }
}

class _PlacesTiles extends ConsumerState<PlacesTiles> {
  // a future to fetch the data from the sql database and update the state of the places provider and use it in the future builder
  late Future<void> _loadedPlaces;
  @override
  void initState() {
    super.initState();

    // calling  the loadPlaces method to update the state when the app starts
    _loadedPlaces = ref.read(favoritePlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    // watching the places provider state(our list of places)
    final places = ref.watch(favoritePlacesProvider);
    Widget content = Center(
      child: Text(
        'No places yet',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    );

    return FutureBuilder(
        future: _loadedPlaces,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          }
          if (places.isEmpty) {
            return content;
          }
          return ListView.builder(
            itemCount: places.length,
            itemBuilder: ((context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: ((context) =>
                              PlaceDetailsScreen(place: places[index])),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundImage: FileImage(
                        places[index].image,
                      ),
                    ),
                    title: Text(
                      places[index].title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                    subtitle: Text(
                      places[index].location.address,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                  ),
                )),
          );
        }));
  }
}
