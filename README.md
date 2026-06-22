# Clash Companion

Cute widgets for Clash of Clans tracking war attacks, hero levels, and donation karma. 
Built with a native iOS SwiftUI app and a Node.js TypeScript backend.

## Project Structure
- `/clash-companion-ios`: The iOS app, built with SwiftUI and WidgetKit.
- `/clash-companion-server`: The Node.js API that safely interfaces with the official Clash of Clans API.

## Local Development Setup

### Backend
1. Open terminal and navigate to the backend folder: `cd clash-companion-server`
2. Install dependencies: `npm install`
3. Copy the `.env.example` file to `.env`: `cp .env.example .env`
4. Add your Clash Developer API Key to the `.env` file.
5. Start the development server: `npm run dev`

**Commands:**
- `npm install` - Install dependencies
- `npm run dev` - Run with hot-reloading (nodemon)
- `npm run build` - Build the TypeScript code
- `npm start` - Run the built output

### iOS App
1. Open `clash-companion-ios/ClashCompanion.xcodeproj` in Xcode.
2. Set up the **App Group** capability (`group.com.yourname.clashcompanion`) for both the main app target and the Widget Extension target.
3. Update the `APIClient.swift` base URL to `http://localhost:3000` (or your local IP/production URL).
4. Build and run the app on the simulator or your device.
5. Add the widgets to your home screen!

## Note on Mock Data
The app supports a mock data mode if you haven't set up the official API yet, which is perfect for designing and testing the widgets.
