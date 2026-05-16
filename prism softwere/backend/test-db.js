
const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');
dotenv.config();

const test = async () => {
    console.log('Testing connection with individual params...');
    const sequelize = new Sequelize({
        database: process.env.DB_NAME,
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        dialect: 'postgres',
        dialectOptions: {
            ssl: {
                require: true,
                rejectUnauthorized: false
            }
        }
    });

    try {
        await sequelize.authenticate();
        console.log('SUCCESS: Connected with SSL');
    } catch (err) {
        console.error('FAILED with SSL:', err.message);

        console.log('Testing without SSL...');
        const sequelizeNoSsl = new Sequelize({
            database: process.env.DB_NAME,
            username: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            host: process.env.DB_HOST,
            port: process.env.DB_PORT,
            dialect: 'postgres'
        });
        try {
            await sequelizeNoSsl.authenticate();
            console.log('SUCCESS: Connected without SSL');
        } catch (err2) {
            console.error('FAILED without SSL:', err2.message);
        }
    }
};

test();
