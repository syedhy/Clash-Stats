import dotenv from 'dotenv';
dotenv.config();

const API_BASE = 'https://api.clashofclans.com/v1';
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

export async function fetchWithCache(endpoint: string, ttlMs: number = DEFAULT_TTL) {
  const cached = cache.get(endpoint);
  if (cached && cached.expiry > Date.now()) {
    return cached.data;
  }

  const data = await fetchFromApi(endpoint);
  cache.set(endpoint, { data, expiry: Date.now() + ttlMs });
  return data;
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
  return fetchWithCache(`/players/${encodedTag}`, 15 * 60 * 1000); // 15 mins
}

export async function getClanWar(clanTag: string) {
  const encodedTag = encodeTag(clanTag);
  return fetchWithCache(`/clans/${encodedTag}/currentwar`, 5 * 60 * 1000); // 5 mins
}
