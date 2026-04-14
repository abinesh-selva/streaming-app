import React from 'react';
import { Trophy, Play, Calendar, Tv } from 'lucide-react';

const CategorySlider = ({ categories }) => {
  const getIcon = (name) => {
    switch (name) {
      case 'Cricket': return <Trophy size={20} />;
      case 'Football': return <Play size={20} />;
      case 'Leagues': return <Calendar size={20} />;
      case 'Live TV': return <Tv size={20} />;
      default: return <Trophy size={20} />;
    }
  };

  return (
    <div style={{ padding: '0 1rem', display: 'flex', gap: '12px', overflowX: 'auto', paddingBottom: '0.5rem' }} className="no-scrollbar">
      {categories.map((cat, index) => (
        <div 
          key={cat.id} 
          className="glass-card" 
          style={{ 
            minWidth: '100px', 
            height: '100px', 
            display: 'flex', 
            flexDirection: 'column', 
            justifyContent: 'center', 
            alignItems: 'center',
            gap: '8px',
            background: index === 0 ? 'rgba(26, 255, 213, 0.1)' : 'var(--bg-glass)',
            borderColor: index === 0 ? 'var(--accent-neon)' : 'var(--glass-border)'
          }}
        >
          <div style={{ color: index === 0 ? 'var(--accent-neon)' : 'var(--text-primary)' }}>
            {getIcon(cat.name)}
          </div>
          <span style={{ fontSize: '0.75rem', fontWeight: 'bold' }}>{cat.name}</span>
        </div>
      ))}
    </div>
  );
};

export default CategorySlider;
