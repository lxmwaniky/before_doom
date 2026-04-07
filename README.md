# Before Doom

![Before Doom Banner](assets/images/banner.jpeg)

MCU rewatch tracker with countdown to **Avengers: Doomsday** (December 18, 2026).

## Features

- **Countdown Timer** - Live countdown to Doomsday in days, hours, minutes, and seconds
- **MCU Watchlist** - Complete chronological watchlist with movies and TV shows
- **Progress Tracking** - Track what you've watched with visual progress indicators
- **Smart Scheduling** - Dynamic schedule that adjusts to your pace
- **Status Ranks** - Earn ranks from Recruit to Legend based on progress
- **Daily Reminders** - Optional push notifications to keep you on track
- **Share Progress** - Share your journey with friends

## Tech Stack

- Flutter 3.35.2 (via FVM)
- flutter_bloc for state management
- Hive for local persistence
- TMDB API for movie metadata

## Getting Started

### Prerequisites
- Flutter 3.35.2 (via FVM)
- A TMDB API key (get one free at https://www.themoviedb.org/settings/api)

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/lxmwaniky/before_doom.git
cd before_doom
```

2. **Set up environment variables**
```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your TMDB API key
# Required: TMDB_API_KEY
```

3. **Install dependencies**
```bash
fvm flutter pub get
```

4. **Run the app**
```bash
fvm flutter run
```

---

Made with Marvel fandom
