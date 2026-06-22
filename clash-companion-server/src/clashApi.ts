import dotenv from 'dotenv';
dotenv.config();

const API_BASE = 'https://cocproxy.royaleapi.dev/v1';
const API_KEY = process.env.COC_API_KEY;

// Simple in-memory cache
const cache = new Map<string, { data: any; expiry: number }>();
const DEFAULT_TTL = parseInt(process.env.CACHE_TTL_SECONDS || '900', 10) * 1000;

function encodeTag(tag: string): string {
  return encodeURIComponent(tag.startsWith('#') ? tag : `#${tag}`);
}

async function fetchFromApi(endpoint: string) {
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

const inFlightRequests = new Map<string, Promise<any>>();

export async function fetchWithCache(endpoint: string, ttlMs: number = DEFAULT_TTL) {
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

export async function verifyPlayerToken(playerTag: string, token: string) {
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

export async function getPlayer(playerTag: string) {
  const encodedTag = encodeTag(playerTag);
  return fetchWithCache(`/players/${encodedTag}`, 5 * 1000); // 5 seconds
}

export async function getClanWar(clanTag: string) {
  const encodedTag = encodeTag(clanTag);
  return fetchWithCache(`/clans/${encodedTag}/currentwar`, 5 * 60 * 1000); // 5 mins
}

export async function getLeagueGroup(clanTag: string) {
  const encodedTag = encodeTag(clanTag);
  return fetchWithCache(`/clans/${encodedTag}/currentwar/leaguegroup`, 5 * 60 * 1000); // 5 mins
}

export async function getClanWarLeagueWar(warTag: string) {
  const encodedTag = encodeTag(warTag);
  return fetchWithCache(`/clanwarleagues/wars/${encodedTag}`, 5 * 60 * 1000); // 5 mins
}
