const sequelize = require('./src/config/database').default || require('./src/config/database');

async function check() {
    try {
        await sequelize.authenticate();
        const [results] = await sequelize.query(`
           SELECT table_name 
           FROM information_schema.tables 
           WHERE table_schema='public'
       `);
        console.log("Tables in DB:", results.map(r => r.table_name));
    } catch (e) {
        console.error(e);
    }
    process.exit(0);
}
check();
