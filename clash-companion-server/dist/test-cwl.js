"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const clashApi_1 = require("./clashApi");
async function test() {
    const group = await (0, clashApi_1.getLeagueGroup)("#282YLR22C");
    console.log(JSON.stringify(group, null, 2));
}
test();
