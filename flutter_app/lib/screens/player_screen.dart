import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/match_model.dart';
import '../widgets/glass_card.dart';

class PlayerScreen extends StatefulWidget {
  final SportMatch match;

  const PlayerScreen({super.key, required this.match});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  int _activeServerIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final server = widget.match.streams![_activeServerIndex];
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(server.url));

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Color(0xFF1AFFD5),
        handleColor: Color(0xFF1AFFD5),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white30,
      ),
    );
    setState(() {});
  }

  void _changeServer(int index) {
    if (_activeServerIndex == index) return;
    setState(() {
      _activeServerIndex = index;
      _chewieController?.dispose();
      _videoPlayerController.dispose();
      _initializePlayer();
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : Center(child: CircularProgressIndicator(color: Color(0xFF1AFFD5))),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF1AFFD5),
              labelColor: Color(0xFF1AFFD5),
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: "STREAM"),
                Tab(text: "SCORECARD"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStreamTab(),
                  _buildScorecardTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.white10),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("← Close & Exit"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: Color(0xFF1AFFD5), shape: BoxShape.circle),
            ),
            SizedBox(width: 8),
            Text("Live Servers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: widget.match.streams!.length,
          itemBuilder: (context, index) {
            final server = widget.match.streams![index];
            final isActive = _activeServerIndex == index;
            return GestureDetector(
              onTap: () => _changeServer(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? Color(0xFF1AFFD5).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  border: Border.all(color: isActive ? Color(0xFF1AFFD5) : Colors.white10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  server.label,
                  style: TextStyle(
                    color: isActive ? Color(0xFF1AFFD5) : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScorecardTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Match Status: MI elected to bat", style: TextStyle(color: Color(0xFF1AFFD5), fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildPlayerRow("Rohit Sharma (c)", "45 (32)"),
              _buildPlayerRow("Ishan Kishan (wk)", "22 (14)"),
              Divider(color: Colors.white10, height: 24),
              _buildPlayerRow("Ravindra Jadeja", "2.2-0-18-1", isBowler: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(String name, String stat, {bool isBowler = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: isBowler ? Colors.white70 : Colors.white)),
          Text(stat, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
