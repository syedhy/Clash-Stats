# Clash Companion - Plan

This is the implementation plan for the Clash Companion iOS App & Backend.

## Architecture Overview
A monorepo structure containing two main folders:
- `/clash-companion-ios`: Native iOS App (SwiftUI, WidgetKit, App Groups, Keychain, URLSession).
- `/clash-companion-server`: Node.js + TypeScript backend (Express) for secure API calls and caching.

## App Screens
1. **Onboarding Screen (3 steps)**: Intro, connection explanation, login form (Player Tag + API Token).
2. **Dashboard Screen**: Connected player info, clan, war status, hero progress, and donation stats.

## Backend Endpoints
- `POST /api/auth/verify`: Verifies player tag and token.
- `GET /api/player/:playerTag/summary`: Overall player & clan info.
- `GET /api/player/:playerTag/heroes`: Hero levels & progress.
- `GET /api/player/:playerTag/donations`: Donation stats & mood.
- `GET /api/player/:playerTag/war`: Widget-friendly war state and countdowns.

## Data Models (iOS)
- `PlayerSummary`, `Hero`, `DonationStats`, `WarStatus` (All Codable)

## Widget List
1. **War Attack Reminder Widget**: Shows war state, attacks left, stars, time left.
2. **Hero Levels Widget**: Shows overall progress percentage or up to 4 heroes' progress.
3. **Donation Tracker Widget**: Shows donated, received, balance, and mood text.

## Known API Limitations
- Widgets cannot guarantee exact 30-minute refresh times; iOS dynamically controls the schedule.
- War data may be hidden if the clan's war log is set to private.
- The Clash API developer key requires IP whitelisting.
