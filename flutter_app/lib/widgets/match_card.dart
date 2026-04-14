import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/match_service.dart';
import 'glass_card.dart';
import 'team_shield.dart';

class MatchCard extends StatelessWidget {
  final SportMatch match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final team1 = MatchService.iplTeams[match.team1];
    final team2 = MatchService.iplTeams[match.team2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.league,
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  if (match.status == MatchStatus.LIVE)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.red, blurRadius: 8)],
                            ),
                          ),
                          SizedBox(width: 6),
                          Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TeamShield(
                          teamShort: match.team1,
                          size: 60,
                          primaryColor: team1?.primaryColor ?? Colors.grey,
                          secondaryColor: team1?.secondaryColor ?? Colors.black,
                        ),
                        SizedBox(height: 8),
                        Text(match.team1, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          match.status == MatchStatus.LIVE ? (match.score1 ?? 'VS') : 'VS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1AFFD5),
                          ),
                        ),
                        if (match.status == MatchStatus.LIVE)
                          Text("(${match.overs1 ?? ''} ov)", style: TextStyle(fontSize: 12, color: Colors.white54)),
                        if (match.status == MatchStatus.UPCOMING)
                          Text(match.startTime ?? '', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TeamShield(
                          teamShort: match.team2,
                          size: 60,
                          primaryColor: team2?.primaryColor ?? Colors.grey,
                          secondaryColor: team2?.secondaryColor ?? Colors.black,
                        ),
                        SizedBox(height: 8),
                        Text(match.team2, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
                  child: Text(
                    match.summary,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
