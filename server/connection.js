const mongoose = require('mongoose');
require('dotenv').config();

async function connectDB() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB Connection Successful!');
    } catch (e) {
        console.error('Connection Error:', e);
        process.exit(1);
    }
}

module.exports = connectDB;