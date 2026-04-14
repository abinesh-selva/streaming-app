export const IPL_TEAMS = {
  CSK: { name: 'Chennai Super Kings', short: 'CSK', color: '#FDB913', secondary: '#0066B3' },
  MI: { name: 'Mumbai Indians', short: 'MI', color: '#004BA0', secondary: '#D1AB3E' },
  RCB: { name: 'Royal Challengers Bengaluru', short: 'RCB', color: '#D11D26', secondary: '#2B2A29' },
  KKR: { name: 'Kolkata Knight Riders', short: 'KKR', color: '#3A225D', secondary: '#B3A123' },
  SRH: { name: 'Sunrisers Hyderabad', short: 'SRH', color: '#FF822A', secondary: '#000000' },
  DC: { name: 'Delhi Capitals', short: 'DC', color: '#000080', secondary: '#FF0000' },
  PBKS: { name: 'Punjab Kings', short: 'PBKS', color: '#ED1B24', secondary: '#D1D3D4' },
  RR: { name: 'Rajasthan Royals', short: 'RR', color: '#EA1A85', secondary: '#004B8D' },
  GT: { name: 'Gujarat Titans', short: 'GT', color: '#1B2133', secondary: '#D1AB3E' },
  LSG: { name: 'Lucknow Super Giants', short: 'LSG', color: '#0057E7', secondary: '#FF4D4D' }
};

export const MOCK_MATCHES = [
  {
    id: 'm1',
    league: 'IPL 2024',
    team1: 'MI',
    team2: 'CSK',
    status: 'LIVE',
    score1: '145/4',
    overs1: '16.2',
    score2: '',
    overs2: '',
    summary: 'MI elected to bat',
    streams: [
      { id: 's1', label: 'Server 1 (HD)', url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8' },
      { id: 's2', label: 'Server 2 (SD)', url: 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8' },
      { id: 's3', label: 'Ultra HD', url: 'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8' }
    ]
  },
  {
    id: 'm2',
    league: 'IPL 2024',
    team1: 'RCB',
    team2: 'KKR',
    status: 'UPCOMING',
    startTime: 'Today, 7:30 PM',
    summary: 'M. Chinnaswamy Stadium, Bengaluru'
  },
  {
    id: 'm3',
    league: 'T20 World Cup',
    team1: 'IND',
    team2: 'PAK',
    status: 'COMPLETED',
    score1: '160/8',
    score2: '158/9',
    summary: 'India won by 2 runs'
  }
];

export const CATEGORIES = [
  { id: 'cat1', name: 'Cricket', icon: 'Cricket' },
  { id: 'cat2', name: 'Football', icon: 'Football' },
  { id: 'cat3', name: 'Leagues', icon: 'Leagues' },
  { id: 'cat4', name: 'Live TV', icon: 'TV' }
];
