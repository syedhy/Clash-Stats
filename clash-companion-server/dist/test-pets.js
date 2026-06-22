"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const API_BASE = 'https://api.clashofclans.com/v1';
const API_KEY = process.env.COC_API_KEY;
async function run() {
    const cRes = await fetch(`${API_BASE}/clans/%232PP`, {
        headers: { Authorization: `Bearer ${API_KEY}` }
    });
    const c = await cRes.json();
    if (!c.memberList)
        return;
    const playerTags = c.memberList.slice(0, 10).map((i) => i.tag);
    const allHomeTroops = new Set();
    for (const tag of playerTags) {
        const pRes = await fetch(`${API_BASE}/players/${encodeURIComponent(tag)}`, {
            headers: { Authorization: `Bearer ${API_KEY}` }
        });
        if (pRes.ok) {
            const p = await pRes.json();
            for (const t of p.troops) {
                if (t.village === 'home') {
                    allHomeTroops.add(t.name);
                }
            }
        }
    }
    console.log(Array.from(allHomeTroops).join(", "));
}
run();
