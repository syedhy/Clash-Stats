import dotenv from 'dotenv';
dotenv.config();

const API_BASE = 'https://api.clashofclans.com/v1';
const API_KEY = process.env.COC_API_KEY;

async function run() {
  const response = await fetch(`${API_BASE}/clans?limit=5&minMembers=40`, {
    headers: { Authorization: `Bearer ${API_KEY}` }
  });
  const data = await response.json();
  const clans = data.items;
  
  for (const clan of clans) {
    const encodedTag = encodeURIComponent(clan.tag);
    const lgRes = await fetch(`${API_BASE}/clans/${encodedTag}/currentwar/leaguegroup`, {
      headers: { Authorization: `Bearer ${API_KEY}` }
    });
    if (lgRes.ok) {
       const lg = await lgRes.json();
       console.log(`Clan ${clan.tag} is in CWL!`);
       
       const validRounds = lg.rounds.filter((r: any) => !r.warTags.includes('#0'));
       console.log(`Valid rounds: ${validRounds.length}`);
       for (let i = validRounds.length - 1; i >= 0; i--) {
         const round = validRounds[i];
         console.log(`Round ${i} warTags:`, round.warTags);
         for (const warTag of round.warTags) {
           const warRes = await fetch(`${API_BASE}/clanwarleagues/wars/${encodeURIComponent(warTag)}`, {
             headers: { Authorization: `Bearer ${API_KEY}` }
           });
           if (warRes.ok) {
             const war = await warRes.json();
             console.log(`  War ${warTag} state: ${war.state} (Clan: ${war.clan?.tag}, Opp: ${war.opponent?.tag})`);
           }
         }
       }
       break;
    }
  }
}
run();
