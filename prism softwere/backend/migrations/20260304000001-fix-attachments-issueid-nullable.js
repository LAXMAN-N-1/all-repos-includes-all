'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.changeColumn('Attachments', 'issueId', {
            type: Sequelize.UUID,
            allowNull: true,
            references: {
                model: 'Issues',
                key: 'id',
            },
            onUpdate: 'CASCADE',
            onDelete: 'CASCADE',
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.changeColumn('Attachments', 'issueId', {
            type: Sequelize.UUID,
            allowNull: false,
            references: {
                model: 'Issues',
                key: 'id',
            },
            onUpdate: 'CASCADE',
            onDelete: 'CASCADE',
        });
    },
};
