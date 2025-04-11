# 🎨 Doodly - Draw, Guess, and Have Fun!

Doodly is a real-time multiplayer drawing and guessing game built with **Flutter** and **Node.js**, inspired by classic games like *Pictionary* and *Skribbl.io*. Unleash your creativity, challenge your friends, and have endless fun drawing and guessing!

---

## 🎮 Key Features

- **Real-time Drawing:** Collaborate on a shared canvas that updates instantly across all players.
- **Room System:** Create or join game rooms with customizable settings.
- **Turn-based Gameplay:** Enjoy a structured game flow with players taking turns to draw.
- **Live Chat:** Communicate and guess in real-time while the drawing unfolds.
- **Scoring System:** Earn points for correct guesses and impressive drawings.
- **Hints & Timers:** Get clues as time counts down to help with the toughest words.
- **Custom Room Settings:** Adjust room size, number of rounds, and other game parameters.
- **User-friendly UI:** Clean, responsive design with smooth animations for a top-notch experience.

---

## 🛠️ Tech Stack

### Frontend

- **Flutter** – for building cross-platform mobile applications
- **Socket.io Client** – for real-time bidirectional communication
- **flutter_colorpicker** – for interactive color selection
- **Custom Animations & Gestures** – for an engaging user interface

### Backend

- **Node.js & Express** – powering the server and API endpoints
- **Socket.io** – handling real-time events and communication
- **MongoDB & Mongoose** – for data storage and persistence

---

## 📦 Dependencies

### Flutter (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  socket_io_client: ^3.1.1
  flutter_colorpicker: ^1.1.0
"dependencies": {
  "axios": "^1.8.4",
  "express": "^5.1.0",
  "http": "^0.0.1-security",
  "mongoose": "^8.13.2",
  "socket.io": "^4.7.2"
}
