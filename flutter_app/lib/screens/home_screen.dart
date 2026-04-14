import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/match_model.dart';
import '../services/match_service.dart';
import '../widgets/match_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SportMatch> _matches = [];
  bool _isLoading = true;
  http.Client? _sseClient;
  Timer? _sseReconnectTimer;
  int _sseRetrySeconds = 2;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _connectSSE();
  }

  @override
  void dispose() {
    _sseClient?.close();
    _sseReconnectTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final matches = await MatchService.fetchMatches();
    if (mounted) {
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    }
  }

  void _connectSSE() {
    _sseClient?.close();
    _sseClient = http.Client();
    final request = http.Request('GET', Uri.parse('${MatchService.baseUrl}/events'));

    _sseClient!.send(request).then((response) {
      _sseRetrySeconds = 2; // Reset backoff on success
      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (line.startsWith('data: ') && mounted) {
            try {
              final data = json.decode(line.substring(6));
              _updateMatchLocally(data);
            } catch (_) {}
          }
        },
        onError: (_) => _scheduleReconnect(),
        onDone: () => _scheduleReconnect(),
        cancelOnError: true,
      );
    }).catchError((Object _) {
      _scheduleReconnect();
    });
  }

  void _scheduleReconnect() {
    if (!mounted) return;
    _sseReconnectTimer?.cancel();
    _sseReconnectTimer = Timer(Duration(seconds: _sseRetrySeconds), () {
      if (mounted) {
        _sseRetrySeconds = (_sseRetrySeconds * 2).clamp(2, 30);
        _connectSSE();
      }
    });
  }

  void _updateMatchLocally(Map<String, dynamic> data) {
    setState(() {
      final index = _matches.indexWhere((m) => m.id == data['id']);
      if (index != -1) {
        _matches[index] = MatchService.parseMatchFromData(data);
      }
    });
  }

  void _onMatchTap(SportMatch match) {
    if (match.status == MatchStatus.LIVE) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(match: match)),
      );
    } else if (match.status == MatchStatus.UPCOMING) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match starts ${match.startTime ?? 'soon'}'),
          backgroundColor: const Color(0xFF1A1A1C),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match has ended'),
          backgroundColor: Color(0xFF1A1A1C),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121214),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings & Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSettingOption(LucideIcons.info, "App Version", "v1.0.0 (Stable)"),
            _buildSettingOption(LucideIcons.shieldCheck, "Privacy Policy", "Read legal terms"),
            _buildSettingOption(LucideIcons.trash2, "Clear Cache", "0.0 MB"),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "Built with love for Sports Fans",
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
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
          Icon(icon, color: const Color(0xFF1AFFD5), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF080808),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1AFFD5)),
        ),
      );
    }

    final filteredMatches = _matches.where((m) {
      final q = _searchQuery.toLowerCase();
      return m.team1.toLowerCase().contains(q) ||
          m.team2.toLowerCase().contains(q) ||
          m.league.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
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
                        SvgPicture.asset('assets/logo.svg', height: 38),
                        IconButton(
                          icon: const Icon(LucideIcons.settings,
                              color: Colors.white54, size: 20),
                          onPressed: () => _showSettings(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: const InputDecoration(
                          icon: Icon(LucideIcons.search,
                              color: Colors.white30, size: 18),
                          hintText: "Search match, team or league...",
                          hintStyle:
                              TextStyle(color: Colors.white30, fontSize: 13),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryItem("Cricket", LucideIcons.trophy, true),
                    _buildCategoryItem(
                        "Football", LucideIcons.playCircle, false),
                    _buildCategoryItem("Leagues", LucideIcons.calendar, false),
                    _buildCategoryItem("Live TV", LucideIcons.tv, false),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle(null, "Live & Upcoming", isLive: true),
            ),
            if (filteredMatches.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                      "No matches found",
                      style: TextStyle(color: Colors.white30, fontSize: 14),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final match = filteredMatches[index];
                    return MatchCard(
                      match: match,
                      onTap: () => _onMatchTap(match),
                    );
                  },
                  childCount: filteredMatches.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSectionTitle(IconData? icon, String title,
      {bool isLive = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          if (isLive)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1AFFD5),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0xFF1AFFD5), blurRadius: 8)
                ],
              ),
            )
          else if (icon != null)
            Icon(icon, size: 20, color: const Color(0xFF1AFFD5)),
          if (icon != null || isLive) const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, bool isActive) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1AFFD5).withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isActive ? const Color(0xFF1AFFD5) : Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isActive ? const Color(0xFF1AFFD5) : Colors.white,
              size: 24),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF080808).withOpacity(0.8),
        border: const Border(top: BorderSide(color: Colors.white10)),
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
        Icon(icon,
            color: isActive ? const Color(0xFF1AFFD5) : Colors.white54,
            size: 22),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: isActive ? const Color(0xFF1AFFD5) : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
