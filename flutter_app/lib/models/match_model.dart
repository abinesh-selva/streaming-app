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
  });
}
