import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../util/url.dart';
import '../querry_model.dart';
import 'rocket.dart';

/// LAUNCH CLASS
/// This class represent a single mission with all its details, like rocket,
/// launchpad, links...
class Launch {
  final int number;
  final String name,
      launchpadId,
      launchpadName,
      imageUrl,
      details,
      tentativePrecision;
  final List<String> links;
  final DateTime launchDate, localLaunchDate, staticFireDate;
  final bool launchSuccess, upcoming, tentativeDate;
  final Rocket rocket;

  Launch({
    this.number,
    this.name,
    this.launchpadId,
    this.launchpadName,
    this.imageUrl,
    this.details,
    this.tentativePrecision,
    this.links,
    this.launchDate,
    this.localLaunchDate,
    this.staticFireDate,
    this.launchSuccess,
    this.upcoming,
    this.tentativeDate,
    this.rocket,
  });

  factory Launch.fromJson(Map<String, dynamic> json) {
    return Launch(
      number: json['flight_number'],
      name: json['mission_name'],
      launchpadId: json['launch_site']['site_id'],
      launchpadName: json['launch_site']['site_name'],
      imageUrl: json['links']['mission_patch_small'],
      details: json['details'],
      tentativePrecision: json['tentative_max_precision'],
      links: [
        json['links']['reddit_campaign'],
        json['links']['video_link'],
        json['links']['presskit'],
        json['links']['article_link'],
      ],
      launchDate: DateTime.parse(json['launch_date_utc']).toLocal(),
      localLaunchDate: DateTime.parse(json['launch_date_local']).toLocal(),
      staticFireDate: setStaticFireDate(json['static_fire_date_utc']),
      launchSuccess: json['launch_success'],
      upcoming: json['upcoming'],
      tentativeDate: json['is_tentative'],
      rocket: Rocket.fromJson(json['rocket']),
    );
  }

  static DateTime setStaticFireDate(String date) {
    try {
      return DateTime.parse(date).toLocal();
    } catch (_) {
      return null;
    }
  }

  String get getNumber => '#$number';

  String get getImageUrl => imageUrl ?? Url.defaultImage;

  String get getDetails => details ?? 'This mission has currently no details.';

  String get getLaunchDate {
    switch (tentativePrecision) {
      case 'hour':
        return '${DateFormat.yMMMMd().addPattern('Hm', ' · ').format(launchDate)} ${launchDate.timeZoneName}';
      case 'day':
        return 'NET ${DateFormat.yMMMMd().format(launchDate)}';
      case 'month':
        return 'NET ${DateFormat.yMMMM().format(launchDate)}';
      case 'quarter':
        return 'NET ${DateFormat.yQQQ().format(launchDate)}';
      default:
        return 'Date not available.';
    }
  }

  String get getLocalLaunchDate =>
      DateFormat.yMMMMd().addPattern('Hm', '  ·  ').format(localLaunchDate);

  String get getUtcLaunchDate =>
      DateFormat.yMMMMd().addPattern('Hm', '  ·  ').format(launchDate.toUtc());

  String get getStaticFireDate => staticFireDate == null
      ? 'Unknown'
      : DateFormat.yMMMMd().format(staticFireDate);
}

class LaunchesModel extends QuerryModel {
  final int type;

  LaunchesModel(this.type);
  
  @override
  Future loadData() async {
    response = await http.get(type == 0 ? Url.upcomingList : Url.launchesList);

    list.clear();
    List jsonDecoded = json.decode(response.body);
    list.addAll(jsonDecoded.map((launch) => Launch.fromJson(launch)).toList());

    loadingState(false);
  }
}
