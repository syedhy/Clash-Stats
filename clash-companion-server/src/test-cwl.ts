import { getLeagueGroup } from './clashApi';
async function test() {
  const group = await getLeagueGroup("#282YLR22C");
  console.log(JSON.stringify(group, null, 2));
}
test();
