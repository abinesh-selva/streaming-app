import React from 'react';

const TeamShield = ({ teamShort, size = 48, teams }) => {
  const team = teams[teamShort] || { color: '#888', secondary: '#333', short: teamShort };
  
  return (
    <div style={{ width: size, height: size, position: 'relative' }}>
      <svg viewBox="0 0 100 100" width={size} height={size}>
        <defs>
          <linearGradient id={`grad-${teamShort}`} x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style={{ stopColor: team.color, stopOpacity: 1 }} />
            <stop offset="100%" style={{ stopColor: team.secondary || team.color, stopOpacity: 1 }} />
          </linearGradient>
        </defs>
        <path 
          d="M50 5 L90 20 L90 50 C90 75 50 95 50 95 C50 95 10 75 10 50 L10 20 L50 5 Z" 
          fill={`url(#grad-${teamShort})`}
          stroke="rgba(255,255,255,0.2)"
          strokeWidth="2"
        />
        <text 
          x="50" 
          y="60" 
          textAnchor="middle" 
          fill="white" 
          fontSize="24" 
          fontWeight="900" 
          fontFamily="system-ui"
          style={{ textShadow: '0 2px 4px rgba(0,0,0,0.5)' }}
        >
          {team.short || teamShort}
        </text>
      </svg>
    </div>
  );
};

export default TeamShield;
