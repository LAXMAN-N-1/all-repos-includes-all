'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface) {
        await queryInterface.sequelize.query(
            'ALTER TABLE "Attachments" ALTER COLUMN "issueId" DROP NOT NULL'
        );
    },

    async down(queryInterface) {
        await queryInterface.sequelize.query(
            'ALTER TABLE "Attachments" ALTER COLUMN "issueId" SET NOT NULL'
        );
    },
};
