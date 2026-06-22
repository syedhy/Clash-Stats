"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const clashApi_1 = require("./clashApi");
async function test() {
    const start = Date.now();
    const player = await (0, clashApi_1.getPlayer)('#PQQRGLJ8');
    const clanTag = player.clan?.tag;
    if (!clanTag)
        return;
    const p1 = (0, clashApi_1.getClanWar)(clanTag).catch(() => null);
    const p2 = (0, clashApi_1.getLeagueGroup)(clanTag).catch(() => null);
    const [cw, lg] = await Promise.all([p1, p2]);
    console.log(`Time taken: ${Date.now() - start}ms`);
}
test();
