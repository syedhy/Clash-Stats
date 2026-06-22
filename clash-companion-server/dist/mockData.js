"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MOCK_WAR_STATUS = exports.MOCK_DONATIONS = exports.MOCK_HEROES = exports.MOCK_PLAYER_SUMMARY = void 0;
exports.MOCK_PLAYER_SUMMARY = {
    tag: "#ABC123",
    name: "Hyder",
    townHallLevel: 13,
    trophies: 4200,
    bestTrophies: 4500,
    leagueName: "Titan League III",
    clanTag: "#CLAN123",
    clanName: "Night Riders",
    donations: 420,
    donationsReceived: 180,
    heroes: [
        { name: "Barbarian King", level: 74, maxLevel: 95, village: "home" },
        { name: "Archer Queen", level: 78, maxLevel: 95, village: "home" },
        { name: "Grand Warden", level: 52, maxLevel: 70, village: "home" },
        { name: "Royal Champion", level: 28, maxLevel: 45, village: "home" }
    ],
    lastUpdated: new Date().toISOString()
};
exports.MOCK_HEROES = {
    heroes: [
        { name: "Barbarian King", level: 74, maxLevel: 95, village: "home", progress: 74 / 95 },
        { name: "Archer Queen", level: 78, maxLevel: 95, village: "home", progress: 78 / 95 },
        { name: "Grand Warden", level: 52, maxLevel: 70, village: "home", progress: 52 / 70 },
        { name: "Royal Champion", level: 28, maxLevel: 45, village: "home", progress: 28 / 45 }
    ]
};
exports.MOCK_DONATIONS = {
    donations: 420,
    donationsReceived: 180,
    balance: 240,
    ratio: 420 / 180,
    mood: "Generous Chief"
};
exports.MOCK_WAR_STATUS = {
    state: "inWar",
    title: "Battle Day",
    clanName: "Night Riders",
    opponentName: "Enemy Clan",
    teamSize: 15,
    attacksPerMember: 2,
    attacksUsed: 1,
    attacksLeft: 1,
    playerStars: 2,
    clanStars: 34,
    opponentStars: 31,
    clanDestruction: 87.4,
    opponentDestruction: 82.1,
    phaseEndsAt: new Date(Date.now() + 5 * 60 * 60 * 1000 + 12 * 60 * 1000).toISOString(), // 5h 12m from now
    warStartTime: new Date(Date.now() - 19 * 60 * 60 * 1000).toISOString(),
    warEndTime: new Date(Date.now() + 5 * 60 * 60 * 1000 + 12 * 60 * 1000).toISOString(),
    lastUpdated: new Date().toISOString()
};
