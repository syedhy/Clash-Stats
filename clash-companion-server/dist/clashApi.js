"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchWithCache = fetchWithCache;
exports.verifyPlayerToken = verifyPlayerToken;
exports.getPlayer = getPlayer;
exports.getClanWar = getClanWar;
exports.getLeagueGroup = getLeagueGroup;
exports.getClanWarLeagueWar = getClanWarLeagueWar;
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const API_BASE = 'https://api.clashofclans.com/v1';
const API_KEY = process.env.COC_API_KEY;
// Simple in-memory cache
const cache = new Map();
const DEFAULT_TTL = parseInt(process.env.CACHE_TTL_SECONDS || '900', 10) * 1000;
function encodeTag(tag) {
    return encodeURIComponent(tag.startsWith('#') ? tag : `#${tag}`);
}
async function fetchFromApi(endpoint) {
    if (!API_KEY) {
        throw new Error('COC_API_KEY is not set');
    }
    const response = await fetch(`${API_BASE}${endpoint}`, {
        headers: {
            Authorization: `Bearer ${API_KEY}`,
            Accept: 'application/json',
        },
    });
    if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(`Clash API Error: ${response.status} - ${errorBody}`);
    }
    return response.json();
}
const inFlightRequests = new Map();
async function fetchWithCache(endpoint, ttlMs = DEFAULT_TTL) {
    const cached = cache.get(endpoint);
    if (cached && cached.expiry > Date.now()) {
        return cached.data;
    }
    // If a request is already happening for this endpoint, wait for it!
    if (inFlightRequests.has(endpoint)) {
        return inFlightRequests.get(endpoint);
    }
    const promise = fetchFromApi(endpoint).then(data => {
        cache.set(endpoint, { data, expiry: Date.now() + ttlMs });
        inFlightRequests.delete(endpoint);
        return data;
    }).catch(error => {
        inFlightRequests.delete(endpoint);
        throw error;
    });
    inFlightRequests.set(endpoint, promise);
    return promise;
}
async function verifyPlayerToken(playerTag, token) {
    if (!API_KEY) {
        throw new Error('COC_API_KEY is not set');
    }
    const encodedTag = encodeTag(playerTag);
    const response = await fetch(`${API_BASE}/players/${encodedTag}/verifytoken`, {
        method: 'POST',
        headers: {
            Authorization: `Bearer ${API_KEY}`,
            Accept: 'application/json',
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ token }),
    });
    if (!response.ok) {
        return false;
    }
    const data = await response.json();
    return data.status === 'ok';
}
async function getPlayer(playerTag) {
    const encodedTag = encodeTag(playerTag);
    return fetchWithCache(`/players/${encodedTag}`, 5 * 1000); // 5 seconds
}
async function getClanWar(clanTag) {
    const encodedTag = encodeTag(clanTag);
    return fetchWithCache(`/clans/${encodedTag}/currentwar`, 5 * 60 * 1000); // 5 mins
}
async function getLeagueGroup(clanTag) {
    const encodedTag = encodeTag(clanTag);
    return fetchWithCache(`/clans/${encodedTag}/currentwar/leaguegroup`, 5 * 60 * 1000); // 5 mins
}
async function getClanWarLeagueWar(warTag) {
    const encodedTag = encodeTag(warTag);
    return fetchWithCache(`/clanwarleagues/wars/${encodedTag}`, 5 * 60 * 1000); // 5 mins
}
