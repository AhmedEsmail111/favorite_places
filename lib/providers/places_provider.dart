import 'dart:io';

import 'package:favorite_places/models/consts.dart';
import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sysPath;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

//  a global method to do the lob of opening the database
Future<Database> _getDatabase() async {
  // open a data base to store the new value in
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: ((db, version) {
      return db.execute(
          'CREATE TABLE $kPlacesTableName(id TEXT PRIMARY KEY, title TEXT, image TEXT ,lat REAL, lng REAL , address TEXT)');
    }),
    version: 1,
  );
  return db;
}

class FavoritePlacesNotifier extends StateNotifier<List<Place>> {
  FavoritePlacesNotifier() : super(const []);

  // a method to load all the places from the database when the app starts
  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query(kPlacesTableName);
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
                latitude: row['lat'] as double,
                longitude: row['lng'] as double,
                address: row['address'] as String),
          ),
        )
        .toList();
    state = places;
  }

  void addPlace(
      {required String title,
      required File image,
      required PlaceLocation location}) async {
    // storing the image on a permanent location on the device
    final appDir = await sysPath.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');
    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();
    db.insert(
      kPlacesTableName,
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
    );
    state = [newPlace, ...state];
  }

  void removePlace(Place place) {
    state = state.where((pl) => pl.id != place.id).toList();
  }
}

final favoritePlacesProvider =
    StateNotifierProvider<FavoritePlacesNotifier, List<Place>>(
  (ref) => FavoritePlacesNotifier(),
);
