const express = require('express'); 
const http = require('http');
const Room = require('./models/room');
const connectDB = require('./connection');
const getWord = require('./api/getWord');

const app = express();
const server = http.createServer(app);
const Port = process.env.PORT || 3000;
var io = require('socket.io')(server);

app.use(express.json());
connectDB();

io.on('connection', (socket) => {
    console.log('connected');
    socket.on('create-game', async({nickname, name, occupancy, maxRounds}) => {
        try {
            console.log(nickname, name, occupancy, maxRounds);
            const existingRoom = await Room.findOne({name});
            if(existingRoom) {
                socket.emit('notCorrectGame', 'Room with that name already exists!');
                return;
            }
            let room = new Room();
            const word = getWord();
            room.word = word;
            room.name = name;
            room.occupancy = occupancy;
            room.maxRounds = maxRounds;

            let player = {
                socketID: socket.id,
                nickname,
                isPartyLeader: true,
            }
            room.players.push(player);
            room = await room.save();
            socket.join(name);
            io.to(name).emit('updateRoom', room);
        } catch(err) {
            console.log(err);
        }
    });

    socket.on('join-game', async({nickname, name}) => {
        try {
            let room = await Room.findOne({name});
            if(!room) {
                socket.emit('notCorrectGame', 'Please enter a valid room name');
                return;
            }

            if(room.isJoin) {
                let player = {
                    socketID: socket.id,
                    nickname,
                }
                room.players.push(player);
                socket.join(name);

                if(room.players.length === room.occupancy) {
                    room.isJoin = false;
                }
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('updateRoom', room);
            } else {
                socket.emit('notCorrectGame', 'The game is in progress, please try later!');
            }
        } catch(err) {
            console.log(err);
        }
    })

    socket.on('msg', async (data) => {
        console.log(data);
        try{
            if(data.msg === data.word) {
                let room = await Room.find({name: data.roomName});
                let userPlayer = room[0].players.filter(
                    (player) => player.nickname === data.username
                )
                if(data.timeTaken !== 0) {
                    userPlayer[0].points += Math.round((200/ data.timeTaken) * 10);
                }
                room = await room[0].save();
                io.to(data.roomName).emit('msg', {
                    username: data.username,
                    msg: 'Guessed it!',
                    guessedUserCtr: data.guessedUserCtr + 1,
                })
                socket.emit('closeInput', "");
            } else {
                io.to(data.roomName).emit('msg', {
                    username: data.username,
                    msg: data.msg,
                    guessedUserCtr: data.guessedUserCtr,
                })
            }
        } catch(err) {
            console.log(err.toString());
        }
    })

    socket.on('change-turn', async(name) => {
        try {
            let room = await Room.findOne({name});
            let idx = room.turnIndex;
            if(idx +1 === room.players.length) {
                room.currentRound+=1;
            }
            if(room.currentRound <= room.maxRounds) {
                const word = getWord();
                room.word = word;
                room.turnIndex = (idx+1) % room.players.length;
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('change-turn', room);
            } else {
                io.to(name).emit("show-leaderboard", room.players);
            }
        } catch(err) {
            console.log(err);
        }
    })

    socket.on('updateScore', async (name) => {
        try {
            const room = await Room.findOne({name});
            io.to(name).emit('updateScore', room);
        } catch(err) {
            console.log(err);
        }
    })

    socket.on('paint', async ({details, roomName}) => {
        try {
          if (!roomName) {
            console.log('Paint event missing roomName');
            return;
          }
          const room = await Room.findOne({ name: roomName });
          if (room.turn.socketID !== socket.id) {
            return;
          }
          io.to(roomName).emit('points', { details: details });
        } catch(err) {
          console.error('Paint handler error:', err);
        }
      });

    // Color socket
    socket.on('color-change', ({color, roomName}) => {
        io.to(roomName).emit('color-change', color);
    })

    // Stroke Socket
    socket.on('stroke-width', ({value, roomName}) => {
        io.to(roomName).emit('stroke-width', Math.min(10, Math.max(1, value)));
    })

    // Clear Screen
    socket.on('clean-screen', (roomName) => {
        io.to(roomName).emit('clear-screen');
    })

    socket.on('disconnect', async() => {
        try {
          let room = await Room.findOne({"players.socketID": socket.id});
          if (!room) {
            console.log('User disconnected but was not in any room');
            return;
          }
          
          for(let i=0; i< room.players.length; i++) {
            if(room.players[i].socketID === socket.id) {
              room.players.splice(i, 1);
              break;
            }
          }
          room = await room.save();
          if(room.players.length === 1) {
            socket.broadcast.to(room.name).emit('show-leaderboard', room.players);
          } else {
            socket.broadcast.to(room.name).emit('user-disconnected', room);
          }
        } catch(err) {
          console.log(err);
        }
      });
})

server.listen(Port, "0.0.0.0",  () => {
    console.log(`Server is running on port ${Port}`);
});
