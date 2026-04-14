import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';

class MatchService {
  // Change this to your machine's LAN IP when testing on a physical device
  // e.g. 'http://192.168.1.10:3001'
  static const String baseUrl = 'http://10.0.2.2:3001';

  // IPL teams
  static final Map<String, Team> iplTeams = {
    'CSK': Team(name: 'Chennai Super Kings',       shortName: 'CSK',  primaryColor: const Color(0xFFFDB913), secondaryColor: const Color(0xFF0066B3)),
    'MI':  Team(name: 'Mumbai Indians',             shortName: 'MI',   primaryColor: const Color(0xFF004BA0), secondaryColor: const Color(0xFFD1AB3E)),
    'RCB': Team(name: 'Royal Challengers Bengaluru',shortName: 'RCB',  primaryColor: const Color(0xFFD11D26), secondaryColor: const Color(0xFF2B2A29)),
    'KKR': Team(name: 'Kolkata Knight Riders',      shortName: 'KKR',  primaryColor: const Color(0xFF3A225D), secondaryColor: const Color(0xFFB3A123)),
    'SRH': Team(name: 'Sunrisers Hyderabad',        shortName: 'SRH',  primaryColor: const Color(0xFFFF822A), secondaryColor: Colors.black),
    'DC':  Team(name: 'Delhi Capitals',             shortName: 'DC',   primaryColor: const Color(0xFF000080), secondaryColor: const Color(0xFFFF0000)),
    'PBKS':Team(name: 'Punjab Kings',               shortName: 'PBKS', primaryColor: const Color(0xFFED1B24), secondaryColor: const Color(0xFFD1D3D4)),
    'RR':  Team(name: 'Rajasthan Royals',           shortName: 'RR',   primaryColor: const Color(0xFFEA1A85), secondaryColor: const Color(0xFF004B8D)),
    'GT':  Team(name: 'Gujarat Titans',             shortName: 'GT',   primaryColor: const Color(0xFF1B2133), secondaryColor: const Color(0xFFD1AB3E)),
    'LSG': Team(name: 'Lucknow Super Giants',       shortName: 'LSG',  primaryColor: const Color(0xFF0057E7), secondaryColor: const Color(0xFFFF4D4D)),
    // International teams
    'IND': Team(name: 'India',       shortName: 'IND', primaryColor: const Color(0xFF0033A0), secondaryColor: const Color(0xFFFF8800)),
    'PAK': Team(name: 'Pakistan',    shortName: 'PAK', primaryColor: const Color(0xFF006600), secondaryColor: const Color(0xFFFFFFFF)),
    'AUS': Team(name: 'Australia',   shortName: 'AUS', primaryColor: const Color(0xFFFFCD00), secondaryColor: const Color(0xFF006400)),
    'ENG': Team(name: 'England',     shortName: 'ENG', primaryColor: const Color(0xFF003366), secondaryColor: const Color(0xFFCE1124)),
    'SA':  Team(name: 'South Africa',shortName: 'SA',  primaryColor: const Color(0xFF007A4D), secondaryColor: const Color(0xFFFFB81C)),
    'NZ':  Team(name: 'New Zealand', shortName: 'NZ',  primaryColor: const Color(0xFF000000), secondaryColor: const Color(0xFFAB192D)),
    'WI':  Team(name: 'West Indies', shortName: 'WI',  primaryColor: const Color(0xFF8B0000), secondaryColor: const Color(0xFFFFD700)),
    'SL':  Team(name: 'Sri Lanka',   shortName: 'SL',  primaryColor: const Color(0xFF003478), secondaryColor: const Color(0xFFFFD700)),
    'BAN': Team(name: 'Bangladesh',  shortName: 'BAN', primaryColor: const Color(0xFF006A4E), secondaryColor: const Color(0xFFFF0000)),
    'AFG': Team(name: 'Afghanistan', shortName: 'AFG', primaryColor: const Color(0xFF0033A0), secondaryColor: const Color(0xFF000000)),
  };

  static Team getTeam(String shortName) {
    return iplTeams[shortName] ??
        Team(
          name: shortName,
          shortName: shortName,
          primaryColor: const Color(0xFF444444),
          secondaryColor: const Color(0xFF222222),
        );
  }

  static Future<List<SportMatch>> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => parseMatchFromData(j)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching matches: $e');
    }
    return [];
  }

  static SportMatch parseMatchFromData(Map<String, dynamic> j) {
    return SportMatch(
      id: j['id'],
      league: j['league'],
      team1: j['team1'],
      team2: j['team2'],
      status: _parseStatus(j['status']),
      score1: j['score1'],
      score2: j['score2'],
      overs1: j['overs1'],
      overs2: j['overs2'],
      summary: j['summary'] ?? '',
      startTime: j['startTime'],
      streams: j['streams'] != null
          ? (j['streams'] as List)
              .map((s) => StreamServer(id: s['id'], label: s['label'], url: s['url']))
              .toList()
          : null,
      scorecard: j['scorecard'] != null ? Scorecard.fromJson(j['scorecard']) : null,
    );
  }

  static MatchStatus _parseStatus(String? status) {
    switch (status) {
      case 'LIVE':      return MatchStatus.LIVE;
      case 'COMPLETED': return MatchStatus.COMPLETED;
      default:          return MatchStatus.UPCOMING;
    }
  }
}
