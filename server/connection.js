const mongoose = require('mongoose');
const password = encodeURIComponent('Samarth@26');

const DB = `mongodb+srv://saysamarth26:${password}@cluster0.vp1c7rv.mongodb.net/skribble?retryWrites=true&w=majority&appName=Cluster0`;

async function connectDB() {
    await mongoose.connect(DB).then(() => {
        console.log('Connection Succesful!');
    }).catch((e) => {
        console.log(e);
    })
}

module.exports = connectDB;
