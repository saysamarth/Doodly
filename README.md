# 🎨 Doodly: Real-Time Drawing & Guessing Game

<div align="center">
  <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/icon2.png" width="150" alt="Doodly Logo"/>
  
  <br/>
  
  **A real-time multiplayer drawing and guessing game built with Flutter and Node.js**

  <br/>

  [![Flutter](https://img.shields.io/badge/Flutter-3.19.3-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Node.js](https://img.shields.io/badge/Node.js-18.17.1-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
  [![MongoDB](https://img.shields.io/badge/MongoDB-8.13.2-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
  [![Socket.io](https://img.shields.io/badge/Socket.io-4.7.2-010101?style=for-the-badge&logo=socket.io&logoColor=white)](https://socket.io/)
  
  [![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square)](http://makeapullrequest.com)
  [![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)

</div>

<br/>

## 📌 Overview

Doodly is an interactive multiplayer game where players take turns drawing while others try to guess what's being drawn. With real-time updates, customizable rooms, and a competitive scoring system, Doodly brings friends together for fun and creative gameplay.

<br/>

## 🎮 Key Features

- **🖌️ Real-time Drawing** - Collaborate on a shared canvas with instant updates
- **🚪 Room System** - Create or join private game rooms with custom settings
- **🔄 Turn-based Gameplay** - Structured game flow with rotating artists
- **💬 Live Chat** - Communicate and guess in real-time during gameplay
- **🏆 Scoring System** - Earn points for correct guesses and creative drawings
- **🎨 Color & Brush Tools** - Express yourself with various drawing tools
- **📱 Responsive Design** - Sleek UI with smooth animations across devices

<br/>

## 📱 App Preview

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/splash.png" width="180"/><br/>
        <b>Splash Screen</b>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/home.png" width="180"/><br/>
        <b>Home Screen</b>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/create.png" width="180"/><br/>
        <b>Create-Room Screen</b>
      </td>
       <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/join.png" width="180"/><br/>
        <b>Join-Room Screen</b>
      </td>
    </tr>
    <tr height="20"></tr>
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/paint.png" width="180"/><br/>
        <b>Drawing Canvas</b>
      </td>
       <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/guessed.png" width="180"/><br/>
        <b>Guessing Phase</b>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/leaderboard.png" width="180"/><br/>
        <b>Leaderboard</b>
      </td>
     <td align="center">
        <img src="https://raw.githubusercontent.com/saysamarth/doodly/main/assets/result.jpg" width="180"/><br/>
        <b>Results Screen</b>
      </td>
    </tr>
  </table>
</div>

<br/>

<details>
<summary><h2>🎬 Watch Gameplay Demo</h2></summary>
<div align="center">
  <a href="https://youtube.com/your-demo-video-1" target="_blank">
    <img src="https://raw.githubusercontent.com/yourusername/doodly/main/assets/screenshots/thumbnail1.jpg" width="400"/>
    <br/>
    <b>▶️ Doodly Gameplay Demo</b>
  </a>
</div>
</details>

<br/>

---

<br/>

## 🛠️ Tech Stack

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/flutter/flutter-original.svg" alt="Flutter" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/nodejs/nodejs-original-wordmark.svg" alt="Node.js" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/nodemon/nodemon-original.svg" alt="nodemon" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/express/express-original.svg" alt="Express" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/mongodb/mongodb-original.svg" alt="MongoDB" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/socketio/socketio-original.svg" alt="Socket" width="50" height="50"/>
</p>

<br/>

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Frontend</b></td>
      <td align="center"><b>Backend</b></td>
    </tr>
    <tr>
      <td>
        <ul>
          <li>Flutter (UI Framework)</li>
          <li>Dart (Programming Language)</li>
          <li>Socket.io Client (Real-time Communication)</li>
          <li>flutter_colorpicker (Color Selection)</li>
          <li>Custom Animations & Gestures</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Node.js (Server Runtime)</li>
          <li>Express (Web Framework)</li>
          <li>Socket.io (WebSocket Communication)</li>
          <li>MongoDB (Database)</li>
          <li>Mongoose (ODM)</li>
        </ul>
      </td>
    </tr>
  </table>
</div>

<br/>

## 📋 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/doodly.git

# Navigate to the Flutter project directory
cd doodly/lib

# Install dependencies
flutter pub get

# Run the app
flutter run
```

```bash
# Navigate to the backend directory
cd doodly/server

# Install dependencies
npm install

# Start the development server
npm run dev
```

---

## 🎯 How to Play

1. **Join or Create a Room** - Enter an existing room code or create your own room.
2. **Invite Friends** - Share your room code with friends to join.
3. **Take Turns** - Each player gets a chance to draw while others guess.
4. **Score Points** - Faster correct guesses earn more points
5. **Have Fun!** - Laugh, compete, and enjoy the creative experience.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request  

---

## 📬 Connect
<div align="center"> 
  <a href="https://www.linkedin.com/in/saysamarth/"> <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"> </a> 
  <a href="mailto:samarth2668@gmail.com"> <img src="https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white" alt="Email"> </a> 
  <a href="https://twitter.com/saysamarth"> <img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" alt="Twitter"> </a> 
</div>
<div align="center"> 
  <sub>Built with ❤️ by Samarth Sharma | MIT License</sub> 
</div>
