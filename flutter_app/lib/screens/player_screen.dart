import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/match_model.dart';
import '../services/match_service.dart';
import '../widgets/glass_card.dart';

class PlayerScreen extends StatefulWidget {
  final SportMatch match;

  const PlayerScreen({super.key, required this.match});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _activeServerIndex = 0;
  bool _isInitializing = false;
  bool _hasError = false;
  late TabController _tabController;
  late Color _accentColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _accentColor = MatchService.getTeam(widget.match.team1).primaryColor;
    if (_accentColor.value == 0xFF444444) _accentColor = const Color(0xFF1AFFD5);

    WakelockPlus.enable(); // Keep screen on while watching

    if (widget.match.streams != null && widget.match.streams!.isNotEmpty) {
      _initializePlayer(0);
    }
  }

  Future<void> _initializePlayer(int serverIndex) async {
    if (_isInitializing) return;

    // Capture old controllers to dispose after mounting new ones
    final oldChewie = _chewieController;
    final oldVideo = _videoController;

    setState(() {
      _chewieController = null;
      _videoController = null;
      _isInitializing = true;
      _hasError = false;
    });

    // Dispose old controllers only after clearing state refs
    oldChewie?.dispose();
    if (oldVideo != null) await oldVideo.dispose();

    if (!mounted) return;

    final server = widget.match.streams![serverIndex];
    final controller = VideoPlayerController.networkUrl(Uri.parse(server.url));

    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF1AFFD5),
          handleColor: const Color(0xFF1AFFD5),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white30,
        ),
      );

      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _activeServerIndex = serverIndex;
        _isInitializing = false;
      });
    } catch (e) {
      controller.dispose();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
          _activeServerIndex = serverIndex;
        });
      }
    }
  }

  void _changeServer(int index) {
    if (index == _activeServerIndex || _isInitializing) return;
    _initializePlayer(index);
  }

  /// On retry, try the next available server; fall back to current if only one.
  void _retryPlayback() {
    final streams = widget.match.streams ?? [];
    if (streams.length > 1) {
      final nextIndex = (_activeServerIndex + 1) % streams.length;
      _initializePlayer(nextIndex);
    } else {
      _initializePlayer(_activeServerIndex);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _chewieController?.dispose();
    _videoController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildPlayer(),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF1AFFD5),
              labelColor: const Color(0xFF1AFFD5),
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'STREAM'),
                Tab(text: 'SCORECARD'),
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
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.white12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Matches'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (widget.match.streams == null || widget.match.streams!.isEmpty) {
      return const Center(
        child: Text('No stream available',
            style: TextStyle(color: Colors.white54)),
      );
    }
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1AFFD5)),
            SizedBox(height: 12),
            Text('Loading stream...',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      );
    }
    if (_hasError) {
      final streams = widget.match.streams ?? [];
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            const Text('Stream unavailable',
                style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _retryPlayback,
              child: Text(
                streams.length > 1 ? 'Try Next Server' : 'Retry',
                style: const TextStyle(color: Color(0xFF1AFFD5)),
              ),
            ),
          ],
        ),
      );
    }
    return _chewieController != null
        ? Chewie(controller: _chewieController!)
        : const SizedBox();
  }

  Widget _buildStreamTab() {
    final streams = widget.match.streams ?? [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Live Servers',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: streams.length,
          itemBuilder: (context, index) {
            final isActive = _activeServerIndex == index && !_hasError;
            return GestureDetector(
              onTap: () => _changeServer(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1AFFD5).withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                      color: isActive
                          ? const Color(0xFF1AFFD5)
                          : Colors.white12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  streams[index].label,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF1AFFD5)
                        : Colors.white,
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
    final sc = widget.match.scorecard;
    if (sc == null) {
      return const Center(
        child: Text('Scorecard not available',
            style: TextStyle(color: Colors.white24)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.match.summary,
                style: const TextStyle(
                    color: Color(0xFF1AFFD5),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('BATSMEN',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              ...sc.batsmen
                  .map((b) =>
                      _buildPlayerRow(b.name, b.stats, isOut: b.isOut))
                  .toList(),
              const Divider(color: Colors.white10, height: 24),
              const Text('BOWLERS',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              ...sc.bowlers
                  .map((b) => _buildPlayerRow(b.name, b.stats,
                      isBowler: true))
                  .toList(),
              if (sc.lastWicket.isNotEmpty) ...[
                const Divider(color: Colors.white10, height: 24),
                const Text('LAST WICKET',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  sc.lastWicket,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                      fontStyle: FontStyle.italic),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(String name, String stat,
      {bool isBowler = false, bool isOut = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isOut
                    ? Colors.white38
                    : (isBowler ? Colors.white70 : Colors.white),
              ),
            ),
          ),
          Text(
            stat,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOut ? Colors.white38 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
