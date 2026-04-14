import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';

class MatchService {
  static const String baseUrl = 'http://localhost:3001';

  static final Map<String, Team> iplTeams = {
    'CSK': Team(name: 'Chennai Super Kings', shortName: 'CSK', primaryColor: Color(0xFFFDB913), secondaryColor: Color(0xFF0066B3)),
    'MI': Team(name: 'Mumbai Indians', shortName: 'MI', primaryColor: Color(0xFF004BA0), secondaryColor: Color(0xFFD1AB3E)),
    'RCB': Team(name: 'Royal Challengers Bengaluru', shortName: 'RCB', primaryColor: Color(0xFFD11D26), secondaryColor: Color(0xFF2B2A29)),
    'KKR': Team(name: 'Kolkata Knight Riders', shortName: 'KKR', primaryColor: Color(0xFF3A225D), secondaryColor: Color(0xFFB3A123)),
    'SRH': Team(name: 'Sunrisers Hyderabad', shortName: 'SRH', primaryColor: Color(0xFFFF822A), secondaryColor: Colors.black),
    'DC': Team(name: 'Delhi Capitals', shortName: 'DC', primaryColor: Color(0xFF000080), secondaryColor: Color(0xFFFF0000)),
    'PBKS': Team(name: 'Punjab Kings', shortName: 'PBKS', primaryColor: Color(0xFFED1B24), secondaryColor: Color(0xFFD1D3D4)),
    'RR': Team(name: 'Rajasthan Royals', shortName: 'RR', primaryColor: Color(0xFFEA1A85), secondaryColor: Color(0xFF004B8D)),
    'GT': Team(name: 'Gujarat Titans', shortName: 'GT', primaryColor: Color(0xFF1B2133), secondaryColor: Color(0xFFD1AB3E)),
    'LSG': Team(name: 'Lucknow Super Giants', shortName: 'LSG', primaryColor: Color(0xFF0057E7), secondaryColor: Color(0xFFFFFF4D4D)),
  };

  static Future<List<SportMatch>> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => parseMatchFromData(json)).toList();
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
    return []; // Return empty or cached data on error
  }

  static SportMatch parseMatchFromData(Map<String, dynamic> json) {
    return SportMatch(
      id: json['id'],
      league: json['league'],
      team1: json['team1'],
      team2: json['team2'],
      status: _parseStatus(json['status']),
      score1: json['score1'],
      score2: json['score2'],
      overs1: json['overs1'],
      overs2: json['overs2'],
      summary: json['summary'],
      startTime: json['startTime'],
      streams: json['streams'] != null 
        ? (json['streams'] as List).map((s) => StreamServer(id: s['id'], label: s['label'], url: s['url'])).toList()
        : null,
    );
  }

  static MatchStatus _parseStatus(String status) {
    switch (status) {
      case 'LIVE': return MatchStatus.LIVE;
      case 'UPCOMING': return MatchStatus.UPCOMING;
      case 'COMPLETED': return MatchStatus.COMPLETED;
      default: return MatchStatus.UPCOMING;
    }
  }
}
