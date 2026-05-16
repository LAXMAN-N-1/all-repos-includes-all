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
        const [results] = await sequelize.query("SELECT id, email, role FROM \"Users\" LIMIT 10");
        console.log('Users found:', results);
    } catch(e) {
        console.error(e);
    } finally {
        await sequelize.close();
    }
}
check();
