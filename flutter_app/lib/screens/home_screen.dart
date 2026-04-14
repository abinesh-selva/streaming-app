import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/match_model.dart';
import '../services/match_service.dart';
import '../widgets/match_card.dart';
import '../widgets/logo_widget.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SportMatch> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setUpSSE();
  }

  Future<void> _loadInitialData() async {
    final matches = await MatchService.fetchMatches();
    setState(() {
      _matches = matches;
      _isLoading = false;
    });
  }

  void _setUpSSE() {
    // Basic SSE implementation using http Client
    final client = http.Client();
    final request = http.Request('GET', Uri.parse('${MatchService.baseUrl}/events'));
    
    client.send(request).then((response) {
      response.stream.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
        if (line.startsWith('data: ')) {
          final data = json.decode(line.substring(6));
          _updateMatchLocally(data);
        }
      });
    }).catchError((e) => print('SSE Error: $e'));
  }

  void _updateMatchLocally(Map<String, dynamic> data) {
    setState(() {
      final index = _matches.indexWhere((m) => m.id == data['id']);
      if (index != -1) {
        // Update the specific match in the list
        final updatedMatch = MatchService.parseMatchFromData(data);
        _matches[index] = updatedMatch;
      }
    });
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF121214),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Settings & Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            _buildSettingOption(LucideIcons.info, "App Version", "v1.0.0 (Stable)"),
            _buildSettingOption(LucideIcons.shieldCheck, "Privacy Policy", "Read legal terms"),
            _buildSettingOption(LucideIcons.trash2, "Clear Cache", "0.0 MB"),
            SizedBox(height: 24),
            Center(child: Text("Build with ❤️ for Sports Fans", style: TextStyle(color: Colors.white24, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF1AFFD5), size: 20),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF080808),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1AFFD5))),
      );
    }

    final filteredMatches = _matches.where((m) {
      return m.team1.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             m.team2.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             m.league.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFF080808),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/logo.svg',
                              height: 38,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.settings, color: Colors.white54, size: 20),
                          onPressed: () => _showSettings(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          icon: Icon(LucideIcons.search, color: Colors.white30, size: 18),
                          hintText: "Search match, team or league...",
                          hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle(LucideIcons.trophy, "Categories"),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryItem("Cricket", LucideIcons.trophy, true),
                    _buildCategoryItem("Football", LucideIcons.playCircle, false),
                    _buildCategoryItem("Leagues", LucideIcons.calendar, false),
                    _buildCategoryItem("Live TV", LucideIcons.tv, false),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle(null, "Live & Upcoming", isLive: true),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final match = filteredMatches[index];
                  return MatchCard(
                    match: match,
                    onTap: () {
                      if (match.status == MatchStatus.LIVE) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlayerScreen(match: match)),
                        );
                      }
                    },
                  );
                },
                childCount: filteredMatches.length,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSectionTitle(IconData? icon, String title, {bool isLive = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          if (isLive)
            Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Color(0xFF1AFFD5),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0xFF1AFFD5), blurRadius: 8)],
              ),
            )
          else if (icon != null)
            Icon(icon, size: 20, color: Color(0xFF1AFFD5)),
          if (icon != null || isLive) SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, bool isActive) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF1AFFD5).withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? Color(0xFF1AFFD5) : Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Color(0xFF1AFFD5) : Colors.white, size: 24),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF080808).withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.home, "Home", true),
          _buildNavItem(LucideIcons.playSquare, "Live TV", false),
          _buildNavItem(LucideIcons.trophy, "Series", false),
          _buildNavItem(LucideIcons.settings, "Settings", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Color(0xFF1AFFD5) : Colors.white54, size: 22),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? Color(0xFF1AFFD5) : Colors.white54, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
