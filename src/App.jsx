import React, { useState } from 'react';
import { Home, PlaySquare, Trophy, Settings } from 'lucide-react';
import { MOCK_MATCHES, CATEGORIES } from './data/mockData';
import MatchCard from './components/MatchCard';
import CategorySlider from './components/CategorySlider';
import VideoPlayer from './components/VideoPlayer';

function App() {
  const [currentScreen, setCurrentScreen] = useState('HOME');
  const [selectedMatch, setSelectedMatch] = useState(null);

  const handleMatchClick = (match) => {
    if (match.status === 'LIVE') {
      setSelectedMatch(match);
      setCurrentScreen('PLAYER');
    }
  };

  return (
    <div className="app-container">
      {currentScreen === 'HOME' && (
        <>
          <header style={{ padding: '1.5rem 1rem 0.5rem' }}>
            <h1 style={{ fontSize: '1.5rem', fontWeight: '900', color: 'var(--text-primary)' }}>
              Cricfy<span style={{ color: 'var(--accent-neon)' }}>TV</span>
            </h1>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-dim)' }}>Watch Live Sports Anywhere</p>
          </header>

          <div className="section-title">
            <Trophy size={20} className="text-neon" />
            Categories
          </div>
          <CategorySlider categories={CATEGORIES} />

          <div className="section-title">
            <div className="pulsing-dot"></div>
            Live & Upcoming
          </div>
          <div className="matches-list">
            {MOCK_MATCHES.map(match => (
              <MatchCard 
                key={match.id} 
                match={match} 
                onClick={() => handleMatchClick(match)} 
              />
            ))}
          </div>

          <nav className="bottom-nav glass">
            <a href="#" className="nav-item active"><Home size={22} /><span>Home</span></a>
            <a href="#" className="nav-item"><PlaySquare size={22} /><span>Live TV</span></a>
            <a href="#" className="nav-item"><Trophy size={22} /><span>Series</span></a>
            <a href="#" className="nav-item"><Settings size={22} /><span>Settings</span></a>
          </nav>
        </>
      )}

      {currentScreen === 'PLAYER' && selectedMatch && (
        <VideoPlayer 
          src={selectedMatch.streams} 
          onBack={() => setCurrentScreen('HOME')} 
        />
      )}
    </div>
  );
}

export default App;
