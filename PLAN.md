# Clash Companion - UI Overhaul Plan

This document outlines the planned UI architecture and visual enhancements for the major UI Overhaul of the Clash Companion app and widgets.

## 1. Global Visual Language
*   **Theme:** Adopt a more premium, "Clash-inspired" aesthetic but keeping it sleek and modern.
*   **Typography:** Use a bold, game-style custom font for headers (similar to Supercell Magic font) and a clean, legible sans-serif for stats and body copy.
*   **Colors & Gradients:** 
    *   Gold/Elixir/Dark Elixir color themes for progression rings and highlights.
    *   Dark Mode first design, utilizing deep blues and dark greys to make vivid game assets pop.

## 2. Main Dashboard Evolution
*   **Modular "Cards":** Break the current long scrolling list into interactive, tap-able cards.
*   **Hero Headers:** The top of the dashboard will feature a prominent player banner showcasing the current League Badge and highest level Hero/Pet.
*   **Dynamic Backgrounds:** Backgrounds will subtly change based on whether it is daytime or nighttime, or based on the player's Town Hall theme.

## 3. Interactive Detail Menus
Instead of displaying all information on one screen, tapping a module will push a new Detailed View:

### War Status Detail View
*   **Trigger:** Tapping the "War Status" or "CWL" card.
*   **Features:**
    *   Live countdown timer emphasizing "Time Left in Phase".
    *   Side-by-side comparison of Our Clan vs Opponent (Stars, Destruction %).
    *   Player's specific attacks used/left, visualized with cool sword icons.

### Laboratory & Troops Detail View
*   **Trigger:** Tapping the "Completion Progress" or "Troops" section.
*   **Features:**
    *   A grid view of all unlocked troops, spells, and siege machines.
    *   Visual indicators (e.g., green glowing max-level badges) for fully upgraded units.
    *   Filtering by Elixir vs Dark Elixir troops.

### Heroes & Pets Detail View
*   **Trigger:** Tapping the "Heroes" section.
*   **Features:**
    *   Large, high-resolution renders of the Heroes.
    *   Equipment assignments visualized clearly below each Hero.
    *   Pet assignments linked to their respective Heroes with chain graphics.

## 4. Widget Enhancements
*   **Dynamic Assets:** Include Hero and Troop images within the widgets to make them visually distinct on the iOS Home Screen.
*   **Live Timers:** Implement timeline-based live countdowns for War Ends/Starts directly in the Widget UI.
*   **Multiple Configurations:** Allow the user to configure widgets to focus solely on War, solely on builder base, or a compact summary of everything.

## 5. Micro-Animations
*   **Loading States:** Replace standard iOS loaders with custom animations (e.g., a bouncing Barbarian or spinning Elixir drop).
*   **Progress Rings:** Animate progress rings filling up when the dashboard loads.
*   **Transitions:** Smooth hero-style transitions when tapping a card to open its detail view.
