import React from 'react';
import TeamShield from './TeamShield';
import { IPL_TEAMS } from '../data/mockData';

const MatchCard = ({ match, onClick }) => {
  return (
    <div className="glass-card" style={{ margin: '0 1rem 1rem', position: 'relative' }} onClick={onClick}>
      <div style={{ padding: '1rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
          <span style={{ fontSize: '0.75rem', fontWeight: 'bold', color: 'var(--text-secondary)' }}>{match.league}</span>
          {match.status === 'LIVE' && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', background: 'rgba(255,0,0,0.1)', padding: '4px 8px', borderRadius: '4px' }}>
              <span className="pulsing-dot" style={{ background: 'var(--accent-red)', boxShadow: '0 0 8px var(--accent-red)' }}></span>
              <span style={{ fontSize: '0.7rem', fontWeight: '900', color: 'var(--accent-red)' }}>LIVE</span>
            </div>
          )}
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ textAlign: 'center', flex: 1 }}>
            <TeamShield teamShort={match.team1} teams={IPL_TEAMS} size={60} />
            <div style={{ marginTop: '8px', fontSize: '0.9rem', fontWeight: 'bold' }}>{match.team1}</div>
          </div>
          
          <div style={{ flex: 1, textAlign: 'center' }}>
            <div style={{ fontSize: '1.25rem', fontWeight: '900', color: 'var(--accent-neon)' }}>
              {match.status === 'LIVE' ? match.score1 : 'VS'}
            </div>
            {match.status === 'LIVE' && <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>({match.overs1} ov)</div>}
            {match.status === 'UPCOMING' && <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>{match.startTime}</div>}
          </div>

          <div style={{ textAlign: 'center', flex: 1 }}>
            <TeamShield teamShort={match.team2} teams={IPL_TEAMS} size={60} />
            <div style={{ marginTop: '8px', fontSize: '0.9rem', fontWeight: 'bold' }}>{match.team2}</div>
          </div>
        </div>

        <div style={{ marginTop: '1rem', paddingTop: '1rem', borderTop: '1px solid var(--glass-border)', fontSize: '0.8rem', color: 'var(--text-secondary)', textAlign: 'center' }}>
          {match.summary}
        </div>
      </div>
    </div>
  );
};

export default MatchCard;
