import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../util/url.dart';
import '../querry_model.dart';

/// LANDPAD MODEL
/// Details about a specific landpad,
/// where boosters can land after completing its mission.
class LandpadModel extends QuerryModel {
  // Landingpad id: OCISLY
  final String id;

  LandpadModel(this.id);

  @override
  Future loadData() async {
    // Get item by http call
    response = await http.get(Url.landingpadDialog + id);

    // Clear old data
    clearItems();

    // Add parsed item
    items.add(Landingpad.fromJson(json.decode(response.body)));

    // Finished loading data
    loadingState(false);
  }

  Landingpad get landingpad => items[0];
}

class Landingpad {
  final String name, status, type, location, state, details, url;
  final List<double> coordinates;
  final int attemptedLandings, successfulLandings;

  Landingpad({
    this.name,
    this.status,
    this.type,
    this.location,
    this.state,
    this.details,
    this.url,
    this.coordinates,
    this.attemptedLandings,
    this.successfulLandings,
  });

  factory Landingpad.fromJson(Map<String, dynamic> json) {
    return Landingpad(
      name: json['full_name'],
      status: json['status'],
      type: json['landing_type'],
      location: json['location']['name'],
      state: json['location']['region'],
      details: json['details'],
      url: json['wikipedia'],
      coordinates: [
        json['location']['latitude'],
        json['location']['longitude'],
      ],
      attemptedLandings: json['attempted_landings'],
      successfulLandings: json['successful_landings'],
    );
  }

  String get getStatus => '${status[0].toUpperCase()}${status.substring(1)}';

  String get getCoordinates =>
      '${coordinates[0].toStringAsPrecision(5)},  ${coordinates[1].toStringAsPrecision(5)}';

  String get getSuccessfulLandings => '$successfulLandings/$attemptedLandings';
}
