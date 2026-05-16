const { Sequelize } = require('sequelize');
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
        console.log('Connected to DB');
        const [results] = await sequelize.query("SELECT * FROM \"Users\" WHERE email = 'gannetz@gmail.com'");
        console.log('User found:', results);
    } catch(e) {
        console.error(e);
    } finally {
        await sequelize.close();
    }
}
check();
