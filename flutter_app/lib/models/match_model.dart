import 'package:flutter/material.dart';

class Team {
  final String name;
  final String shortName;
  final Color primaryColor;
  final Color secondaryColor;

  Team({
    required this.name,
    required this.shortName,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

enum MatchStatus { LIVE, UPCOMING, COMPLETED }

class StreamServer {
  final String id;
  final String label;
  final String url;

  StreamServer({required this.id, required this.label, required this.url});
}

class PlayerStat {
  final String name;
  final String stats;
  final bool isOut;

  PlayerStat({required this.name, required this.stats, this.isOut = false});

  factory PlayerStat.fromJson(Map<String, dynamic> json) => PlayerStat(
    name: json['name'],
    stats: json['stats'],
    isOut: json['isOut'] ?? false,
  );
}

class BowlerStat {
  final String name;
  final String stats;

  BowlerStat({required this.name, required this.stats});

  factory BowlerStat.fromJson(Map<String, dynamic> json) => BowlerStat(
    name: json['name'],
    stats: json['stats'],
  );
}

class Scorecard {
  final List<PlayerStat> batsmen;
  final List<BowlerStat> bowlers;
  final String lastWicket;

  Scorecard({required this.batsmen, required this.bowlers, required this.lastWicket});

  factory Scorecard.fromJson(Map<String, dynamic> json) => Scorecard(
    batsmen: (json['batsmen'] as List).map((b) => PlayerStat.fromJson(b)).toList(),
    bowlers: (json['bowlers'] as List).map((b) => BowlerStat.fromJson(b)).toList(),
    lastWicket: json['lastWicket'] ?? '',
  );
}

class SportMatch {
  final String id;
  final String league;
  final String team1;
  final String team2;
  final MatchStatus status;
  final String? score1;
  final String? score2;
  final String? overs1;
  final String? overs2;
  final String summary;
  final String? startTime;
  final List<StreamServer>? streams;
  final Scorecard? scorecard;

  SportMatch({
    required this.id,
    required this.league,
    required this.team1,
    required this.team2,
    required this.status,
    this.score1,
    this.score2,
    this.overs1,
    this.overs2,
    required this.summary,
    this.startTime,
    this.streams,
    this.scorecard,
  });
}
