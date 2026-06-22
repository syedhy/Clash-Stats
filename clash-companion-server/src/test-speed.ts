import { getPlayer, getClanWar, getLeagueGroup } from './clashApi';
async function test() {
  const start = Date.now();
  const player = await getPlayer('#PQQRGLJ8');
  const clanTag = player.clan?.tag;
  if (!clanTag) return;
  
  const p1 = getClanWar(clanTag).catch(() => null);
  const p2 = getLeagueGroup(clanTag).catch(() => null);
  
  const [cw, lg] = await Promise.all([p1, p2]);
  console.log(`Time taken: ${Date.now() - start}ms`);
}
test();
