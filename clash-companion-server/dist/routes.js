"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const mockData_1 = require("./mockData");
const clashApi_1 = require("./clashApi");
const router = (0, express_1.Router)();
const useMock = !process.env.COC_API_KEY || process.env.COC_API_KEY === 'your_clash_developer_api_key';
router.post('/auth/verify', async (req, res) => {
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
                tag: mockData_1.MOCK_PLAYER_SUMMARY.tag,
                name: mockData_1.MOCK_PLAYER_SUMMARY.name,
                townHallLevel: mockData_1.MOCK_PLAYER_SUMMARY.townHallLevel,
                clanTag: mockData_1.MOCK_PLAYER_SUMMARY.clanTag,
                clanName: mockData_1.MOCK_PLAYER_SUMMARY.clanName,
            }
        });
        return;
    }
    try {
        const isValid = await (0, clashApi_1.verifyPlayerToken)(playerTag, playerApiToken);
        if (!isValid) {
            res.status(401).json({ success: false, error: 'Invalid token' });
            return;
        }
        const player = await (0, clashApi_1.getPlayer)(playerTag);
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
    }
    catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});
router.get('/player/:playerTag/summary', async (req, res) => {
    const playerTag = req.params.playerTag;
    if (useMock) {
        res.json(mockData_1.MOCK_PLAYER_SUMMARY);
        return;
    }
    try {
        const player = await (0, clashApi_1.getPlayer)(playerTag);
        res.json({
            tag: player.tag,
            name: player.name,
            townHallLevel: player.townHallLevel,
            trophies: player.trophies,
            bestTrophies: player.bestTrophies,
            leagueName: player.leagueTier?.name || player.league?.name,
            leagueIconUrl: player.leagueTier?.iconUrls?.small || player.league?.iconUrls?.small,
            attackWins: player.attackWins,
            defenseWins: player.defenseWins,
            builderHallLevel: player.builderHallLevel,
            builderBaseTrophies: player.builderBaseTrophies,
            bestBuilderBaseTrophies: player.bestBuilderBaseTrophies,
            clanTag: player.clan?.tag,
            clanName: player.clan?.name,
            clanBadgeUrl: player.clan?.badgeUrls?.small,
            donations: player.donations,
            donationsReceived: player.donationsReceived,
            heroes: player.heroes,
            lastUpdated: new Date().toISOString()
        });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/player/:playerTag/heroes', async (req, res) => {
    const playerTag = req.params.playerTag;
    if (useMock) {
        res.json(mockData_1.MOCK_HEROES);
        return;
    }
    try {
        const player = await (0, clashApi_1.getPlayer)(playerTag);
        const heroes = (player.heroes || []).map((h) => ({
            name: h.name,
            level: h.level,
            maxLevel: h.maxLevel,
            village: h.village,
            progress: h.maxLevel > 0 ? h.level / h.maxLevel : 0,
            iconUrl: getHeroIconUrl(h.name),
            equipment: h.equipment?.map((eq) => ({
                name: eq.name,
                level: eq.level,
                maxLevel: eq.maxLevel
            })) || []
        }));
        res.json({ heroes });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/player/:playerTag/laboratory', async (req, res) => {
    const playerTag = req.params.playerTag;
    if (useMock) {
        res.json({ troops: [], spells: [] }); // Need mock data if needed, but we can return empty for mock
        return;
    }
    try {
        const player = await (0, clashApi_1.getPlayer)(playerTag);
        const mapItem = (item) => ({
            name: item.name,
            level: item.level,
            maxLevel: item.maxLevel,
            village: item.village,
            progress: item.level / item.maxLevel
        });
        const troops = (player.troops || []).map(mapItem);
        const spells = (player.spells || []).map(mapItem);
        // Separate Hero Pets from normal home village troops
        const petNames = new Set(["L.A.S.S.I", "Mighty Yak", "Electro Owl", "Unicorn", "Diggy", "Frosty", "Poison Lizard", "Phoenix", "Spirit Fox", "Angry Jelly", "Sneezy", "Greedy Raven"]);
        const regularTroops = troops.filter((t) => !petNames.has(t.name));
        const pets = troops.filter((t) => petNames.has(t.name));
        res.json({ troops: regularTroops, spells, pets });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/player/:playerTag/donations', async (req, res) => {
    const playerTag = req.params.playerTag;
    if (useMock) {
        res.json(mockData_1.MOCK_DONATIONS);
        return;
    }
    try {
        const player = await (0, clashApi_1.getPlayer)(playerTag);
        const donations = player.donations || 0;
        const donationsReceived = player.donationsReceived || 0;
        const balance = donations - donationsReceived;
        const ratio = donationsReceived === 0 ? (donations > 0 ? donations : 0) : donations / donationsReceived;
        let mood = "Perfectly Balanced";
        if (donations === 0 && donationsReceived === 0)
            mood = "No season data yet";
        else if (balance > 300)
            mood = "Generous Chief";
        else if (balance > 0)
            mood = "Helpful Clanmate";
        else if (balance < 0)
            mood = "Needs To Donate";
        res.json({
            donations,
            donationsReceived,
            balance,
            ratio,
            mood
        });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
async function resolveWarStatus(playerTag, player) {
    if (!player.clan) {
        return { state: "notInClan", title: "No Clan", lastUpdated: new Date().toISOString() };
    }
    const { getClanWar, getLeagueGroup, getClanWarLeagueWar } = require('./clashApi');
    const [cw, leagueGroup] = await Promise.all([
        getClanWar(player.clan.tag).catch((e) => {
            if (e.message?.includes('403'))
                return { state: "privateWarLog" };
            return null;
        }),
        getLeagueGroup(player.clan.tag).catch(() => null)
    ]);
    if (cw?.state === 'privateWarLog') {
        return { state: "privateWarLog", title: "War Hidden", lastUpdated: new Date().toISOString() };
    }
    if (cw && cw.state !== 'notInWar') {
        const attacksPerMember = cw.attacksPerMember || 1;
        const member = cw.clan?.members?.find((m) => m.tag === playerTag);
        return {
            state: cw.state, title: cw.state === 'inWar' ? 'Battle Day' : cw.state === 'preparation' ? 'Preparation Day' : 'War Ended',
            clanName: cw.clan?.name || 'Your Clan', opponentName: cw.opponent?.name || 'Opponent', teamSize: cw.teamSize,
            attacksPerMember, attacksUsed: member?.attacks?.length || 0, attacksLeft: member ? (attacksPerMember - (member.attacks?.length || 0)) : 0,
            playerStars: member?.attacks?.reduce((sum, a) => sum + a.stars, 0) || 0,
            playerDestruction: member?.attacks?.length ? (member.attacks.reduce((sum, a) => sum + a.destructionPercentage, 0) / member.attacks.length) : 0,
            clanStars: cw.clan?.stars || 0, opponentStars: cw.opponent?.stars || 0,
            clanDestruction: cw.clan?.destructionPercentage || 0, opponentDestruction: cw.opponent?.destructionPercentage || 0,
            phaseEndsAt: cw.endTime, warStartTime: cw.startTime, warEndTime: cw.endTime, lastUpdated: new Date().toISOString()
        };
    }
    if (leagueGroup && leagueGroup.state && leagueGroup.state !== 'notInWar') {
        const validRounds = leagueGroup.rounds.filter((r) => !r.warTags.includes('#0'));
        const allWarTags = validRounds.flatMap((r) => r.warTags);
        const allWars = await Promise.all(allWarTags.map((tag) => getClanWarLeagueWar(tag).catch(() => null)));
        const ourWars = allWars.filter((w) => w && (w.clan?.tag === player.clan.tag || w.opponent?.tag === player.clan.tag));
        let activeWar = ourWars.find((w) => w.state === 'inWar');
        if (!activeWar)
            activeWar = ourWars.find((w) => w.state === 'preparation');
        if (!activeWar)
            activeWar = ourWars.sort((a, b) => new Date(b.endTime).getTime() - new Date(a.endTime).getTime())[0];
        if (activeWar) {
            let myClan = activeWar.clan;
            let enemyClan = activeWar.opponent;
            if (activeWar.opponent?.tag === player.clan.tag) {
                myClan = activeWar.opponent;
                enemyClan = activeWar.clan;
            }
            const member = myClan?.members?.find((m) => m.tag === playerTag);
            const attacksUsed = member ? (member.attacks?.length || 0) : 0;
            const attacksPerMember = activeWar.attacksPerMember || 1;
            const attacksLeft = member ? attacksPerMember - attacksUsed : 0;
            let title = "CWL: Prep Day";
            let phaseEndsAt = activeWar.startTime;
            if (activeWar.state === 'inWar') {
                title = "Clan War League";
                phaseEndsAt = activeWar.endTime;
            }
            else if (activeWar.state === 'warEnded') {
                title = "CWL: War Ended";
                phaseEndsAt = activeWar.endTime;
            }
            const calcStars = (c) => {
                if (c?.stars !== undefined)
                    return c.stars;
                if (!c?.members)
                    return 0;
                return c.members.reduce((sum, m) => sum + (m.attacks?.reduce((s, a) => s + a.stars, 0) || 0), 0);
            };
            const calcDestruction = (c) => {
                if (c?.destructionPercentage !== undefined)
                    return c.destructionPercentage;
                if (!c?.members || c.members.length === 0)
                    return 0;
                const totalDestruction = c.members.reduce((sum, m) => sum + (m.attacks?.reduce((s, a) => Math.max(s, a.destructionPercentage), 0) || 0), 0);
                return totalDestruction / activeWar.teamSize;
            };
            return {
                state: "inCWL", title, clanName: myClan?.name, opponentName: enemyClan?.name, teamSize: activeWar.teamSize,
                attacksPerMember, attacksUsed, attacksLeft,
                playerStars: member ? member.attacks?.reduce((sum, a) => sum + a.stars, 0) : 0,
                playerDestruction: (member && member.attacks && member.attacks.length > 0) ? (member.attacks.reduce((sum, a) => sum + a.destructionPercentage, 0) / member.attacks.length) : 0,
                clanStars: calcStars(myClan), opponentStars: calcStars(enemyClan),
                clanDestruction: calcDestruction(myClan), opponentDestruction: calcDestruction(enemyClan),
                phaseEndsAt, warStartTime: activeWar.startTime, warEndTime: activeWar.endTime, lastUpdated: new Date().toISOString()
            };
        }
    }
    return {
        state: "notInWar",
        title: "Not in War",
        lastUpdated: new Date().toISOString()
    };
}
router.get('/player/:playerTag/war', async (req, res) => {
    const playerTag = req.params.playerTag;
    if (useMock) {
        res.json(mockData_1.MOCK_WAR_STATUS);
        return;
    }
    try {
        const player = await (0, clashApi_1.getPlayer)(playerTag);
        const warStatus = await resolveWarStatus(playerTag, player);
        res.json(warStatus);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Asset mappings
const ASSETS_BASE_URL = "https://raw.githubusercontent.com/ClashKingInc/ClashKingAssets/master/assets";
const heroImageMap = {
    "Barbarian King": "Icon_HV_Hero_Barbarian_King.png",
    "Archer Queen": "Icon_HV_Hero_Archer_Queen.png",
    "Grand Warden": "Icon_HV_Hero_Grand_Warden.png",
    "Royal Champion": "Icon_HV_Hero_Royal_Champion.png",
    "Minion Prince": "Icon_HV_Hero_Minion_Prince.png",
    "Dragon Duke": "Icon_HV_Hero_Dragon_Duke.webp"
};
function getHeroIconUrl(name) {
    const filename = heroImageMap[name];
    return filename ? `${ASSETS_BASE_URL}/home-base/hero-pics/${filename}` : undefined;
}
function getTroopIconUrl(name) {
    let formatted = name.toLowerCase().replace(/\./g, '').replace(/ /g, '_');
    // Handle edge cases like Super Troops if necessary, but for now this works for normal troops
    return `${ASSETS_BASE_URL}/troops/${formatted}/icon.webp`;
}
function getSpellIconUrl(name) {
    let formatted = name.toLowerCase().replace(/ /g, '_');
    return `${ASSETS_BASE_URL}/spells/${formatted}.webp`;
}
function getPetIconUrl(name) {
    let formatted = name.toLowerCase().replace(/\./g, '').replace(/ /g, '_');
    return `${ASSETS_BASE_URL}/pets/${formatted}/icon.webp`;
}
router.get('/player/:playerTag/dashboard', async (req, res) => {
    const playerTag = req.params.playerTag;
    try {
        const player = await (0, clashApi_1.getPlayer)(playerTag);
        // Summary
        const summary = {
            tag: player.tag, name: player.name, townHallLevel: player.townHallLevel,
            trophies: player.trophies, bestTrophies: player.bestTrophies,
            leagueName: player.leagueTier?.name || player.league?.name,
            leagueIconUrl: player.leagueTier?.iconUrls?.small || player.league?.iconUrls?.small,
            clanTag: player.clan?.tag,
            clanName: player.clan?.name, donations: player.donations,
            donationsReceived: player.donationsReceived,
            builderHallLevel: player.builderHallLevel,
            builderBaseTrophies: player.builderBaseTrophies,
            bestBuilderBaseTrophies: player.bestBuilderBaseTrophies,
            attackWins: player.attackWins, defenseWins: player.defenseWins,
            heroes: (player.heroes || []).filter((h) => h.village === 'home').map((h) => ({
                name: h.name, level: h.level, maxLevel: h.maxLevel, village: h.village,
                iconUrl: getHeroIconUrl(h.name),
                equipment: h.equipment ? h.equipment.map((e) => ({ name: e.name, level: e.level, maxLevel: e.maxLevel })) : undefined
            })),
            lastUpdated: new Date().toISOString()
        };
        // Heroes
        const heroesList = (player.heroes || []).filter((h) => h.village === 'home').map((h) => ({
            name: h.name, level: h.level, maxLevel: h.maxLevel, village: h.village, progress: h.maxLevel > 0 ? h.level / h.maxLevel : 0,
            iconUrl: getHeroIconUrl(h.name),
            equipment: h.equipment ? h.equipment.map((e) => ({ name: e.name, level: e.level, maxLevel: e.maxLevel })) : undefined
        }));
        // Donations
        const d = player.donations || 0;
        const r = player.donationsReceived || 0;
        const ratio = r > 0 ? Number((d / r).toFixed(2)) : d > 0 ? d : 0;
        let mood = "Neutral";
        if (d > r * 2 && d > 100)
            mood = "Generous Chief";
        else if (r > d * 2 && r > 100)
            mood = "Leech";
        else if (d > 500)
            mood = "Active Donator";
        const donations = { donations: d, donationsReceived: r, balance: d - r, ratio, mood };
        // Laboratory
        const petNames = new Set(["L.A.S.S.I", "Mighty Yak", "Electro Owl", "Unicorn", "Diggy", "Frosty", "Poison Lizard", "Phoenix", "Spirit Fox", "Angry Jelly", "Sneezy", "Greedy Raven"]);
        const troopsData = (player.troops || []).filter((t) => t.village === 'home').map((t) => ({
            name: t.name, level: t.level, maxLevel: t.maxLevel, village: t.village || 'home',
            progress: t.maxLevel > 0 ? t.level / t.maxLevel : 0,
            iconUrl: petNames.has(t.name) ? getPetIconUrl(t.name) : getTroopIconUrl(t.name)
        }));
        const spellsData = (player.spells || []).map((t) => ({
            name: t.name, level: t.level, maxLevel: t.maxLevel, village: t.village || 'home',
            progress: t.maxLevel > 0 ? t.level / t.maxLevel : 0,
            iconUrl: getSpellIconUrl(t.name)
        }));
        const regularTroops = troopsData.filter((t) => !petNames.has(t.name));
        const petsData = troopsData.filter((t) => petNames.has(t.name));
        const laboratory = { troops: regularTroops, spells: spellsData, pets: petsData };
        // Completion Progress Calculation
        let heroCurrent = 0, heroMax = 0;
        heroesList.forEach((h) => {
            heroCurrent += h.level;
            heroMax += h.maxLevel;
        });
        let labCurrent = 0, labMax = 0;
        const allLabItems = [...regularTroops, ...spellsData, ...petsData];
        allLabItems.forEach((item) => {
            labCurrent += item.level;
            labMax += item.maxLevel;
        });
        const completionProgress = {
            heroes: heroMax > 0 ? Math.round((heroCurrent / heroMax) * 100) : 0,
            laboratory: labMax > 0 ? Math.round((labCurrent / labMax) * 100) : 0
        };
        // War Status
        const warStatus = await resolveWarStatus(playerTag, player);
        res.json({
            summary,
            heroes: heroesList,
            donations,
            warStatus,
            laboratory,
            completionProgress
        });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
exports.default = router;
