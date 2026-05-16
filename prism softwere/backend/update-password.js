const { Sequelize } = require('sequelize');
const bcrypt = require('bcryptjs'); // standard bcrypt is empty, trying bcryptjs
const dotenv = require('dotenv');
dotenv.config();

const sequelize = new Sequelize({
    database: process.env.DB_NAME,
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    dialectOptions: { ssl: { require: true, rejectUnauthorized: false } }
});

async function check() {
    try {
        await sequelize.authenticate();
        // The project uses bcrypt. Let's hash the password 'password123'
        const passwordHash = await bcrypt.hash('password123', 10);
        
        await sequelize.query(`UPDATE "Users" SET "passwordHash" = '${passwordHash}' WHERE email = 'laxmanlaxman1629@gmail.com'`);
        console.log('Password updated successfully to: password123');
    } catch(e) {
        console.error(e);
    } finally {
        await sequelize.close();
    }
}
check();
