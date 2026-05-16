import { QueryTypes } from 'sequelize';
import sequelize from '../../src/config/database';

export const resetDatabase = async (): Promise<void> => {
    await sequelize.authenticate();

    const tables = await sequelize.query<{ tablename: string }>(
        `SELECT tablename
         FROM pg_tables
         WHERE schemaname = 'public'
           AND tablename <> 'SequelizeMeta'`,
        { type: QueryTypes.SELECT }
    );

    if (tables.length === 0) {
        return;
    }

    const tableNames = tables.map(({ tablename }) => `"${tablename}"`).join(', ');
    await sequelize.query(`TRUNCATE TABLE ${tableNames} RESTART IDENTITY CASCADE;`);
};
