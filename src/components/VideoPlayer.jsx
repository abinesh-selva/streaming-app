import React, { useEffect, useRef, useState } from 'react';
import videojs from 'video.js';
import 'video.js/dist/video-js.css';

const VideoPlayer = ({ src, onBack }) => {
  const videoRef = useRef(null);
  const playerRef = useRef(null);
  const [activeServer, setActiveServer] = useState(0);

  useEffect(() => {
    // Initialize video.js player
    if (!playerRef.current) {
      const videoElement = videoRef.current;
      if (!videoElement) return;

      const player = playerRef.current = videojs(videoElement, {
        autoplay: true,
        controls: true,
        responsive: true,
        fluid: true,
        sources: [{
          src: src[activeServer].url,
          type: 'application/x-mpegURL'
        }]
      });
    } else {
      // Update source on server change
      const player = playerRef.current;
      player.src({
        src: src[activeServer].url,
        type: 'application/x-mpegURL'
      });
    }
  }, [src, activeServer]);

  // Dispose the player on unmount
  useEffect(() => {
    const player = playerRef.current;
    return () => {
      if (player) {
        player.dispose();
        playerRef.current = null;
      }
    };
  }, [playerRef]);

  const [activeTab, setActiveTab] = useState('STREAM');

  return (
    <div className="player-view" style={{ background: '#080808', minHeight: '100vh' }}>
      <div className="player-container" style={{ position: 'relative' }}>
        <div data-vjs-player>
          <video ref={videoRef} className="video-js vjs-big-play-centered" />
        </div>
      </div>

      <div className="player-tabs" style={{ display: 'flex', borderBottom: '1px solid var(--glass-border)', background: 'var(--bg-surface)' }}>
        <button 
          className={`btn-tab ${activeTab === 'STREAM' ? 'active' : ''}`} 
          style={{ flex: 1, borderRadius: 0 }}
          onClick={() => setActiveTab('STREAM')}
        >
          Stream
        </button>
        <button 
          className={`btn-tab ${activeTab === 'SCORE' ? 'active' : ''}`} 
          style={{ flex: 1, borderRadius: 0 }}
          onClick={() => setActiveTab('SCORE')}
        >
          Scorecard
        </button>
      </div>

      <div className="player-content-sections" style={{ padding: '1.5rem 1rem' }}>
        {activeTab === 'STREAM' ? (
          <>
            <h3 style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1rem' }}>
              <span className="pulsing-dot"></span> 
              Live Servers
            </h3>
            
            <div className="server-tabs" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
              {src.map((server, index) => (
                <button
                  key={server.id}
                  className={`server-btn ${activeServer === index ? 'active' : ''}`}
                  onClick={() => setActiveServer(index)}
                >
                  {server.label}
                </button>
              ))}
            </div>
          </>
        ) : (
          <div className="scorecard-view">
            <div className="glass-card" style={{ padding: '1rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                <span style={{ fontWeight: 'bold', color: 'var(--accent-neon)' }}>Match Status: MI elected to bat</span>
              </div>
              
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                  <span>Rohit Sharma (c)</span>
                  <span>45 (32)</span>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                  <span>Ishan Kishan (wk)</span>
                  <span>22 (14)</span>
                </div>
                <div style={{ height: '1px', background: 'var(--glass-border)', margin: '4px 0' }}></div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                  <span>Ravindra Jadeja</span>
                  <span>2.2-0-18-1</span>
                </div>
              </div>
            </div>
          </div>
        )}

        <div style={{ marginTop: '2rem' }}>
          <button 
            className="btn-tab" 
            style={{ width: '100%', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--glass-border)', color: 'var(--text-dim)' }}
            onClick={onBack}
          >
            ← Close & Exit
          </button>
        </div>
      </div>
    </div>
  );
};

export default VideoPlayer;
