# BoundaryCric Streaming App — Full Audit

> [!WARNING]
> **Memory Management Issues Found**: The Flutter app has several memory-related problems including SSE connection leaks, missing video controller disposal on hot-navigation, and no image/widget cache management.

## 🔴 Memory Issues (Critical)

### 1. SSE Client Never Reconnects & Leaks on Error
**File:** [home_screen.dart](file:///var/www/html/myInnov/streaming-app/flutter_app/lib/screens/home_screen.dart#L46-L63)

The `_setUpSSE()` method creates an `http.Client` but:
- **No reconnection logic** — if the SSE connection drops (network switch, server restart), it's gone forever for that session.
- **No heartbeat/keepalive** — stale connections will silently hang, consuming memory.
- The `response.stream` subscription is never cancelled in `dispose()` — only the client is closed. The stream listener can outlive the widget.

```diff
 @override
 void dispose() {
+  _sseSubscription?.cancel();
   _sseClient?.close();
   super.dispose();
 }
```

### 2. VideoPlayerController Disposal Race Condition
**File:** [player_screen.dart](file:///var/www/html/myInnov/streaming-app/flutter_app/lib/screens/player_screen.dart#L39-L96)

In `_initializePlayer()`:
- The old `ChewieController` and `VideoPlayerController` are disposed **before** the new one is created — this is correct.
- **BUT** if the user presses back (Navigator.pop) *while* `_initializePlayer` is awaiting `controller.initialize()`, the `dispose()` method runs and disposes `_chewieController` / `_videoController` (which are `null` at that point), but the new `controller` variable that's still initializing is **never disposed**. It leaks.

```dart
// Line 60-64: controller.initialize() is awaited, but if dispose() 
// fires during this await, controller is orphaned in memory.
await controller.initialize();
if (!mounted) {
  controller.dispose(); // ✅ This exists, but only catches the mounted check
  return;
}
```
This part is actually handled, but there's a subtler issue: if the user rapidly taps between servers (calling `_changeServer` multiple times), the `if (_isInitializing) return;` guard prevents a new init, but the **in-flight** controller from the first call will still complete and set state on a potentially disposed widget.

### 3. No Image/Asset Cache Management
- The `google_fonts` package downloads fonts at runtime — no offline fallback configured.
- The `flutter_svg` asset (`assets/logo.svg`) is loaded but never cached via `precachePicture`.
- No `AutomaticKeepAliveClientMixin` on any scrollable — each scroll rebuild reconstructs all `TeamShield` `CustomPaint` widgets from scratch.

### 4. Match List Grows Unbounded
**File:** [home_screen.dart](file:///var/www/html/myInnov/streaming-app/flutter_app/lib/screens/home_screen.dart#L65-L74)

`_updateMatchLocally()` only updates existing matches. If the backend pushes a **new** match via SSE, it's silently ignored. But more critically, the `_matches` list is never pruned — completed matches accumulate forever in memory during a session.

---

## 🟡 Missing Features (vs. Implementation Plan)

### From [task.md](file:///home/dialedin/.gemini/antigravity/brain/579e6599-87a7-46fb-b22b-caaa510a7ca4/task.md):

| Feature | Status |
|---|---|
| Search & Filter on Home Screen | ✅ Implemented |
| Settings Page (About, Feedback, Cache clear) | ⚠️ Partial — modal only, no real cache clear logic |
| "Reminder" functionality (Local Notifications) | ❌ Missing |
| Splash Screen & App Icon branding | ❌ Missing |
| Hero animations (card → player) | ❌ Missing (was in implementation plan) |
| DELETE match endpoint (backend) | ❌ Missing |
| Auth-protected API | ❌ Missing |
| Admin: Stream Link Updater | ❌ Missing |
| Admin: Live Score Controller | ⚠️ Partial — only score1/overs1/summary editable |

### Backend Gaps
**File:** [server.js](file:///var/www/html/myInnov/streaming-app/backend/server.js)

- **No DELETE endpoint** — matches can be created and updated, but never removed.
- **No authentication** — anyone can POST to `/matches` and modify data.
- **SSE doesn't broadcast new matches** — only `notifyClients()` is called on update, not on create.
- **Admin dashboard** doesn't support: adding new matches, deleting, editing score2/overs2, or managing stream links.

---

## 🟢 What's Working Well

- ✅ Clean Flutter architecture (models/services/screens/widgets separation)
- ✅ SSE real-time score updates (basic flow)
- ✅ Backend API with JSON file persistence
- ✅ HLS video playback with Chewie
- ✅ Server switching in player
- ✅ Team branding with `CustomPaint` shields
- ✅ Glassmorphic UI with `BackdropFilter`
- ✅ Search filtering on home screen
- ✅ Comprehensive team data (IPL + International)

---

## 🔧 Recommended Fix Priority

1. **Fix SSE stream subscription leak** (dispose the StreamSubscription, add reconnect)
2. **Guard VideoPlayer disposal** (track in-flight controllers, cancel on dispose)
3. **Add match list pruning** (limit completed matches in memory)
4. **Add `precachePicture` for SVG** and consider `RepaintBoundary` on `TeamShield`
5. **Implement missing features** from task.md (splash, notifications, admin improvements)

---

> [!IMPORTANT]
> **Do you want me to fix the memory issues now?** I can patch the SSE leak, the video controller race condition, and add proper cache management. Let me know which ones to prioritize.
