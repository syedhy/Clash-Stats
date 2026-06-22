import { Router, Request, Response } from 'express';
import { MOCK_PLAYER_SUMMARY, MOCK_HEROES, MOCK_DONATIONS, MOCK_WAR_STATUS } from './mockData';
import { getPlayer, getClanWar, verifyPlayerToken } from './clashApi';

const router = Router();

const useMock = !process.env.COC_API_KEY || process.env.COC_API_KEY === 'your_clash_developer_api_key';

router.post('/auth/verify', async (req: Request, res: Response): Promise<void> => {
  const { playerTag, playerApiToken } = req.body;

  if (!playerTag || !playerApiToken) {
    res.status(400).json({ success: false, error: 'Missing playerTag or playerApiToken' });
    return;
  }

  if (useMock) {
    // Mock success
    res.json({
      success: true,
      player: {
        tag: MOCK_PLAYER_SUMMARY.tag,
        name: MOCK_PLAYER_SUMMARY.name,
        townHallLevel: MOCK_PLAYER_SUMMARY.townHallLevel,
        clanTag: MOCK_PLAYER_SUMMARY.clanTag,
        clanName: MOCK_PLAYER_SUMMARY.clanName,
      }
    });
    return;
  }

  try {
    const isValid = await verifyPlayerToken(playerTag, playerApiToken);
    if (!isValid) {
      res.status(401).json({ success: false, error: 'Invalid token' });
      return;
    }

    const player = await getPlayer(playerTag);
    res.json({
      success: true,
      player: {
        tag: player.tag,
        name: player.name,
        townHallLevel: player.townHallLevel,
        clanTag: player.clan?.tag,
        clanName: player.clan?.name,
      }
    });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/player/:playerTag/summary', async (req: Request, res: Response): Promise<void> => {
  const playerTag = req.params.playerTag as string;

  if (useMock) {
    res.json(MOCK_PLAYER_SUMMARY);
    return;
  }

  try {
    const player = await getPlayer(playerTag);
    res.json({
      tag: player.tag,
      name: player.name,
      townHallLevel: player.townHallLevel,
      trophies: player.trophies,
      bestTrophies: player.bestTrophies,
      leagueName: player.league?.name,
      leagueIconUrl: player.league?.iconUrls?.small,
      clanTag: player.clan?.tag,
      clanName: player.clan?.name,
      clanBadgeUrl: player.clan?.badgeUrls?.small,
      donations: player.donations,
      donationsReceived: player.donationsReceived,
      heroes: player.heroes,
      lastUpdated: new Date().toISOString()
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/player/:playerTag/heroes', async (req: Request, res: Response): Promise<void> => {
  const playerTag = req.params.playerTag as string;

  if (useMock) {
    res.json(MOCK_HEROES);
    return;
  }

  try {
    const player = await getPlayer(playerTag);
    const heroes = (player.heroes || []).map((h: any) => ({
      name: h.name,
      level: h.level,
      maxLevel: h.maxLevel,
      village: h.village,
      progress: h.level / h.maxLevel
    }));
    res.json({ heroes });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/player/:playerTag/donations', async (req: Request, res: Response): Promise<void> => {
  const playerTag = req.params.playerTag as string;

  if (useMock) {
    res.json(MOCK_DONATIONS);
    return;
  }

  try {
    const player = await getPlayer(playerTag);
    const donations = player.donations || 0;
    const donationsReceived = player.donationsReceived || 0;
    const balance = donations - donationsReceived;
    const ratio = donationsReceived === 0 ? (donations > 0 ? donations : 0) : donations / donationsReceived;
    
    let mood = "Perfectly Balanced";
    if (donations === 0 && donationsReceived === 0) mood = "No season data yet";
    else if (balance > 300) mood = "Generous Chief";
    else if (balance > 0) mood = "Helpful Clanmate";
    else if (balance < 0) mood = "Needs To Donate";

    res.json({
      donations,
      donationsReceived,
      balance,
      ratio,
      mood
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/player/:playerTag/war', async (req: Request, res: Response): Promise<void> => {
  const playerTag = req.params.playerTag as string;

  if (useMock) {
    res.json(MOCK_WAR_STATUS);
    return;
  }

  try {
    const player = await getPlayer(playerTag);
    if (!player.clan) {
      res.json({
        state: "notInClan",
        title: "No Clan",
        lastUpdated: new Date().toISOString()
      });
      return;
    }

    let war;
    try {
      war = await getClanWar(player.clan.tag);
    } catch (e: any) {
      if (e.message.includes('403')) {
        res.json({ state: "privateWarLog", title: "War Hidden", lastUpdated: new Date().toISOString() });
        return;
      }
      throw e;
    }

    if (war.state === 'notInWar') {
      res.json({ state: "notInWar", title: "No War", lastUpdated: new Date().toISOString() });
      return;
    }

    // Find player in clan members
    const member = war.clan?.members?.find((m: any) => m.tag === player.tag);
    const attacksUsed = member ? (member.attacks?.length || 0) : 0;
    const attacksPerMember = war.attacksPerMember || 2;
    const attacksLeft = member ? attacksPerMember - attacksUsed : 0;

    let title = "Preparation Day";
    let phaseEndsAt = war.startTime;
    if (war.state === 'inWar') {
      title = "Battle Day";
      phaseEndsAt = war.endTime;
    } else if (war.state === 'warEnded') {
      title = "War Ended";
      phaseEndsAt = war.endTime; // Not used but returned
    }

    res.json({
      state: war.state,
      title,
      clanName: war.clan?.name,
      opponentName: war.opponent?.name,
      teamSize: war.teamSize,
      attacksPerMember,
      attacksUsed,
      attacksLeft,
      playerStars: member ? member.attacks?.reduce((sum: number, a: any) => sum + a.stars, 0) : 0,
      clanStars: war.clan?.stars,
      opponentStars: war.opponent?.stars,
      clanDestruction: war.clan?.destructionPercentage,
      opponentDestruction: war.opponent?.destructionPercentage,
      phaseEndsAt,
      warStartTime: war.startTime,
      warEndTime: war.endTime,
      lastUpdated: new Date().toISOString()
    });

  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
